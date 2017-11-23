'use strict';

import {fromAscii} from './helpers/Bytes32Helper';
import EVMThrow from './helpers/EVMThrow';

const Gateway = artifacts.require('Gateway');
const Base = artifacts.require('Base');
const BaseContract = artifacts.require('BaseContract');
const Questionnaire = artifacts.require('Questionnaire');
const Offer = artifacts.require('OfferContract');
const CAToken = artifacts.require('CAToken');
const HolderAdCoins = artifacts.require('HolderAdCoins');

const BigNumber = web3.BigNumber;
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

contract('BaseContract', function ([_, advertiserWallet, firstClientWallet, secondClientWallet]) {

    const catokenDecimals = new BigNumber(3);
    const catokenIncrease = new BigNumber(10).pow(catokenDecimals);
    
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

    const offerMinReward = new BigNumber(100).mul(catokenIncrease);
    const offerMaxReward = new BigNumber(2000).mul(catokenIncrease);

    const rulesActions = [3, 3, 1]; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
    const rulesRewardPercents = [60, 20, 20]; //total of items can be 100;

    const offerUrl = 'http://www.toyota-global.com/';
    const offerDesc = 'this is crossover of toyota motors. Best of the best!? =)';
    const offerImageUrl = 'https://goo.gl/CLmzaC';

    const offerBalance = new BigNumber(10000).mul(catokenIncrease);

    it('init', async function () {
        this.gateway = await Gateway.new();

        const baseContractAddress = (await BaseContract.new()).address;
        await this.gateway.setBaseContract(baseContractAddress);

        this.baseContract = Base.at(await this.gateway.baseContract());

        this.tokensContract = await CAToken.new();
        await this.baseContract.setTokensContract(this.tokensContract.address);
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

        await offer.setRules(
            offerMinReward,
            offerMaxReward,
            rulesKeys,
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

    it('base contract on pause', async function () {
        await this.baseContract.pause();

        assert.ok(await this.baseContract.paused(), "incorrect state of contract: not paused");
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
