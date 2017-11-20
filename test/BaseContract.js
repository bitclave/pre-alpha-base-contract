'use strict';

import {fromAscii} from './helpers/Bytes32Helper';
import EVMThrow from './helpers/EVMThrow';

const Gateway = artifacts.require('Gateway');
const Base = artifacts.require('Base');
const BaseContract = artifacts.require('BaseContract');
const Questionnaire = artifacts.require('Questionnaire');
const Offer = artifacts.require('OfferContract');
const Search = artifacts.require('Search');
const SearchRequest = artifacts.require('SearchRequest');
const SearchContract = artifacts.require('SearchContract');
const CAToken = artifacts.require('CAToken');
const HolderAdCoins = artifacts.require('HolderAdCoins');

const BigNumber = web3.BigNumber;
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const сatokenDecimals = new BigNumber(3);
const сatokenIncrease = new BigNumber(10).pow(сatokenDecimals);

contract('BaseContract', function ([_, advertiserWallet, firstClientWallet, secondClientWallet]) {

    const groupName = 'cleaning';
    const steps = ['numbers of rooms?', 'How many times a week?', 'What time?'];
    const stepIsCheckbox = [false, false, true];
    const variants = [
        ['one room', 'two room', 'three and more rooms'],
        ['once', 'every monday', 'only on weekends'],
        ['morning at 8 - 10 am', 'at noon', 'evening'],
    ];

    const rulesKeys = [
        fromAscii('salary', 32),
        fromAscii('age', 32),
        fromAscii('country', 32)];

    const offerUserDataValues = [
        fromAscii('5000', 32),
        fromAscii('18', 32),
        fromAscii('russia', 32)];

    const offerMinReward = new BigNumber(100).mul(сatokenIncrease);
    const offerMaxReward = new BigNumber(2000).mul(сatokenIncrease);

    const rulesActions = [3, 3, 1]; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
    const rulesRewardPercents = [60, 20, 20]; //total of items can be 100;

    const offerUrl = 'http://www.toyota-global.com/';
    const offerDesc = 'this is crossover of toyota motors. Best of the best!? =)';
    const offerImageUrl = 'https://goo.gl/CLmzaC';

    const offerBalance = new BigNumber(10000).mul(сatokenIncrease);

    it('init', async function () {
        this.searchRequestContract = null;

        this.gateway = await Gateway.new();

        const baseContractAddress = (await BaseContract.new()).address;
        await this.gateway.setBaseContract(baseContractAddress);

        this.baseContract = Base.at(await this.gateway.baseContract());

        this.tokensContract = await CAToken.new();
        await this.baseContract.setTokensContract(this.tokensContract.address);

        this.searchContract = await SearchContract.new(this.baseContract.address);

        await this.searchContract.setBaseContract(this.baseContract.address);
        await this.baseContract.setSearchContract(this.searchContract.address);
    });

    it('add client data keys', async function () {
        await this.searchContract.addClientDataKeys(rulesKeys);
        let keys = await this.searchContract.getClientDataKeys();
        keys.length.should.be.equal(rulesKeys.length);

        await this.searchContract.addClientDataKeys(rulesKeys);
        keys = await this.searchContract.getClientDataKeys();
        keys.length.should.be.equal(rulesKeys.length);
    });

    it('create questionnaire and add to the BaseContract', async function () {
        const questionnaire = await Questionnaire.new();
        await questionnaire.setGroupName(fromAscii(groupName, 32));

        for (let i = 0; i < steps.length; i++) {
            await questionnaire.addStep(steps[i], stepIsCheckbox[i]);
        }
        const variantsBytes32 = [];
        for (let i = 0; i < variants.length; i++) {
            variantsBytes32.length = 0;
            for (let j = 0; j < variants[i].length; j++) {
                variantsBytes32.push(fromAscii(variants[i][j], 32));
            }
            await questionnaire.addVariants(i, variantsBytes32);
        }

        await this.baseContract.addQuestionnaire(questionnaire.address);

        const listOfQuestionnaire = await this.baseContract.getQuestionnaires();

        assert.equal(listOfQuestionnaire.length, 1, 'incorrect count of questionnaire');
        listOfQuestionnaire[0].should.be.equal(questionnaire.address);
    });

    it('create new offer', async function () {
        const listOfQuestionnaire = await this.baseContract.getQuestionnaires();
        assert.equal(listOfQuestionnaire.length, 1, 'incorrect count of questionnaire');

        const questionnaireAddress = Questionnaire.at(listOfQuestionnaire[0]).address;

        await this.baseContract.createOffer(questionnaireAddress, {from: advertiserWallet});
        const offers = await this.baseContract.getAdvertiserOffers({from: advertiserWallet});

        offers.length.should.be.equal(1);

        const offer = Offer.at(offers[0]);

        const advertiser = await offer.advertiser();
        advertiser.should.be.equal(advertiserWallet);

        const offerQuestionnaire = await offer.questionnaireAddress();
        offerQuestionnaire.should.be.equal(questionnaireAddress);
    });

    it('setup offer with questionnaire steps', async function () {
        const offers = await this.baseContract.getAdvertiserOffers({from: advertiserWallet});
        const offer = Offer.at(offers[0]);
        //step 1 - 14. where it's any selected variant (any of three) == (1 << 1) + (1 << 2) + (1 << 3 )
        // step 2 - 4 . second selected variant. (1 << 2);
        //step 3 - 12. two selected variant's. (one and three) (1 << 2) + (1 << 3);
        const steps = [14, 4, 12];
        await offer.setQuestionnaireSteps(steps);
        const stepsFromOffer = await offer.getQuestionnaireSteps();

        assert.deepEqualNumber(stepsFromOffer, steps);
    });

    it('other wallet no have offers', async function () {
        const offers = await this.baseContract.getAdvertiserOffers({from: firstClientWallet});
        offers.length.should.be.equal(0)
    });

    it('update offer', async function () {
        const offers = await this.baseContract.getAdvertiserOffers({from: advertiserWallet});
        const offer = Offer.at(offers[0]);

        await offer.setOfferInfo(
            offerUrl,
            offerDesc,
            offerImageUrl,
            {from: advertiserWallet});

        const clientDataKeys = await this.searchContract.getClientDataKeys();

        await offer.setRules(
            offerMinReward,
            offerMaxReward,
            clientDataKeys,
            offerUserDataValues,
            rulesActions,
            rulesRewardPercents,
            {from: advertiserWallet}
        );

        const updatedOffer = await offer.getOffer();
        updatedOffer.length.should.be.equal(4);
        updatedOffer[1].should.be.equal(offerUrl);
        updatedOffer[2].should.be.equal(offerDesc);
        updatedOffer[3].should.be.equal(offerImageUrl);

        const updatedRules = await offer.getRules();
        updatedRules.length.should.be.equal(6);
        updatedRules[0].should.bignumber.equal(offerMinReward);
        updatedRules[1].should.bignumber.equal(offerMaxReward);
        updatedRules[2].length.should.be.equal(updatedRules[3].length);
        updatedRules[3].length.should.be.equal(updatedRules[4].length);
        updatedRules[4].length.should.be.equal(updatedRules[5].length);

        assert.deepEqual(updatedRules[2], rulesKeys, 'incorrect array of Keys');
        assert.deepEqual(updatedRules[3], offerUserDataValues, 'incorrect array of Values');

        assert.deepEqualNumber(updatedRules[4], rulesActions);
        assert.deepEqualNumber(updatedRules[5], rulesRewardPercents);
    });

    it('search with negative balance on offer holder of coins', async function () {
        const searchData = [4, 4, 8];
        const listOfQuestionnaire = await this.baseContract.getQuestionnaires();

        this.searchRequestContract = await SearchRequest.new(listOfQuestionnaire[0], searchData, _,
            {from: firstClientWallet});

        await this.searchContract.searchOffers(this.searchRequestContract.address, rulesKeys,
            offerUserDataValues, {from: firstClientWallet});

        const result = await this.searchRequestContract.getResultLength();
        result.should.be.bignumber.equal(0);
    });

    it('pay for offer balance', async function () {
        const offers = await this.baseContract.getAdvertiserOffers({from: advertiserWallet});
        const offer = Offer.at(offers[0]);
        const holder = HolderAdCoins.at(await offer.holderCoins.call());
        let balance = await holder.getBalance();

        balance.should.be.bignumber.equal(0);

        //advertiserWallet no have tokens
        await this.tokensContract.transfer(holder.address, offerBalance, {from: advertiserWallet})
            .should
            .be
            .rejectedWith(EVMThrow);

        await this.tokensContract.transfer(holder.address, offerBalance);
        balance = await holder.getBalance();
        balance.should.be.bignumber.equal(offerBalance);
    });

    const searchWithExpectedResult = async function () {
        const searchData = [4, 4, 8];
        const listOfQuestionnaire = await this.baseContract.getQuestionnaires();

        this.searchRequestContract = await SearchRequest.new(listOfQuestionnaire[0], searchData, _,
            {from: firstClientWallet});

        await this.searchContract.searchOffers(this.searchRequestContract.address, rulesKeys,
            offerUserDataValues, {from: firstClientWallet});

        const result = await this.searchRequestContract.getResultLength();
        result.should.be.bignumber.equal(1);
    };

    const payRewardForClient = async function () {
        await this.searchRequestContract.result(1).should
            .be
            .rejectedWith(EVMThrow);

        const offerAddress = await this.searchRequestContract.result(0);

        const giveReward = await this.searchRequestContract.getRewardByOffer(offerAddress);
        const viewedCount = await this.searchRequestContract.getNumberOfViews(offerAddress);

        //80 - this is - rulesRewardPercents = [60 (salary), 20 (age), 20 (country)]; and matching 80%  (salary and age)
        const defPercentsOfMatching = new BigNumber(80).div(viewedCount.plus(1));
        const calculatedReward = offerMaxReward.mul(defPercentsOfMatching).div(100);
        giveReward.should.be.bignumber.equal(calculatedReward);
        const oldClientBalance = await this.tokensContract.balanceOf(firstClientWallet);

        await this.baseContract.transferClientRewards(offerAddress, this.searchRequestContract.address, {from: firstClientWallet});

        const clientBalance = await this.tokensContract.balanceOf(firstClientWallet);
        clientBalance.should.be.bignumber.equal(oldClientBalance.plus(giveReward));

        const reward = await this.searchRequestContract.getRewardByOffer(offerAddress);
        reward.should.be.bignumber.equal(0);

        const offer = Offer.at(offerAddress);
        const holder = HolderAdCoins.at(await offer.holderCoins.call());
        const offerUpdatedBalance = await holder.getBalance();
        offerUpdatedBalance.should.be.bignumber.equal(offerBalance.minus(clientBalance));
    };

    it('search with positive balance on offer holder of coins', searchWithExpectedResult);

    it('give to client his reward after search', payRewardForClient);

    it('search with positive balance on offer holder of coins', searchWithExpectedResult);

    it('give to client his reward after search', payRewardForClient);

    it('change client data and search', async function () {
        const otherData = [
            fromAscii('1000', 32),
            fromAscii('10', 32),
            fromAscii('usa', 32)];

        const clientDataKeys = await this.searchContract.getClientDataKeys();
        offerUserDataValues.length.should.be.equal(clientDataKeys.length);

        const searchData = [4, 4, 8];
        const listOfQuestionnaire = await this.baseContract.getQuestionnaires();

        this.searchRequestContract = await SearchRequest.new(listOfQuestionnaire[0], searchData, _,
            {from: firstClientWallet});

        await this.searchContract.searchOffers(this.searchRequestContract.address, rulesKeys,
            otherData, {from: firstClientWallet});

        const result = await this.searchRequestContract.getResult();

        result.length.should.be.equal(0);
    });

    it('base contract on pause', async function () {
        await this.baseContract.pause();

        assert.ok(await this.baseContract.paused(), "incorrect state of contract: not paused");
    });

    it('clone base contract', async function () {
        await this.gateway.setBaseContract((await BaseContract.new()).address);
        this.baseContractSecond = Base.at(await this.gateway.baseContract());
        await this.baseContract.cloneContract(this.baseContractSecond.address);
        this.searchContract = Search.at(await this.baseContractSecond.searchContract());
    });

    it('destroy old base contract', async function () {
        await this.baseContract.destroy();
        const owner = await this.baseContract.owner();
        owner.should.be.equal('0x');
        this.baseContract = null;
    });

    it('search contract on pause', async function () {
        await this.searchContract.pause();

        assert.ok(await this.searchContract.paused(), "incorrect state of contract: not paused");
    });

    it('clone search contract', async function () {
        const newSearchContract = await SearchContract.new(this.baseContractSecond.address);
        await this.baseContractSecond.setSearchContract(newSearchContract.address);
        this.searchContractSecond = Search.at(await this.baseContractSecond.searchContract());

        await this.searchContract.cloneContract(this.searchContractSecond.address);
    });

    it('destroy old search contract', async function () {
        await this.searchContract.destroy();
        const owner = await this.searchContract.owner();
        owner.should.be.equal('0x');
        this.searchContract = null;
    });

    makeSuite('validate cloned data:', async function () {
        it('validate contract addresses', async function () {
            this.tokensContract.address.should.be.equal(await this.baseContractSecond.tokenContract());
            this.searchContractSecond.address.should.be.equal(await this.baseContractSecond.searchContract());
        });

        it('other wallet no have offers', async function () {
            const offers = await this.baseContractSecond.getAdvertiserOffers({from: firstClientWallet});
            offers.length.should.be.equal(0)
        });

        it('wallet has offers', async function () {
            const offers = await this.baseContractSecond.getAdvertiserOffers({from: advertiserWallet});
            offers.length.should.be.equal(1);
        });

        it('has questionnaires', async function () {
            const listOfQuestionnaire = await this.baseContractSecond.getQuestionnaires();

            assert.equal(listOfQuestionnaire.length, 1, 'incorrect count of questionnaire');
        });
    });

    function makeSuite(name, tests) {
        describe(name, async function () {
            tests();
        });
    }

    assert.deepEqualNumber = function (arrayNumber1, arrayNumber2) {
        arrayNumber1.length.should.be.equal(arrayNumber2.length);

        for (let i = 0; i < arrayNumber1.length; i++) {
            arrayNumber1[i].should.be.bignumber.equal(arrayNumber2[i]);
        }
    };

});
