'use strict';

import {fromAscii, toAscii} from './helpers/Bytes32Helper';

const Questionnaire = artifacts.require('Questionnaire');
const BigNumber = web3.BigNumber;
const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

contract('Questionnaire', function ([_, wallet]) {

    const groupName = 'cleaning';
    const steps = ['numbers of rooms?', 'How many times a week?', 'What time?'];
    const stepIsCheckbox = [false, false, true];
    const variants = [
        ['one room', 'two room', 'three and more rooms', 'variant4', 'variant5', 'variant6', 'variant7', "variant8", "variant9", "variant10", 'variant5', 'variant6', 'variant7', "variant8", "variant9", "variant10", 'variant5', 'variant6', 'variant7', "variant8", "variant9", "variant10", 'variant5', 'variant6', 'variant7', "variant8", "variant9", "variant10"],
        ['once', 'every monday', 'only on weekends', 'variant4', 'variant5', 'variant6', 'variant7', "variant8"],
        ['morning at 8 - 10 am', 'at noon', 'evening'],
    ];

    it('initialize', async function () {
        this.contract = await Questionnaire.new();
    });

    it('set group name', async function () {
        await this.contract.setGroupName(fromAscii(groupName, 32));
        let name = toAscii(await this.contract.groupName.call());
        name.should.be.equal(groupName);
    });

    it('add new step', async function () {
        for (let i = 0; i < steps.length; i++) {
            await this.contract.addStep(steps[i], stepIsCheckbox[i]);
            let stepInfo = await this.contract.getStepInfo(i);

            stepInfo[0].should.be.equal(steps[i]);
            stepInfo[1].should.be.equal(stepIsCheckbox[i]);
        }
    });

    it('add new variants', async function () {
        const variantsBytes32 = [];
        for (let i = 0; i < steps.length; i++) {
            variantsBytes32.length = 0;

            for (let j = 0; j < variants[i].length; j++) {
                variantsBytes32.push(fromAscii(variants[i][j], 32));
            }

            await this.contract.addVariants(i, variantsBytes32);

            let resultList = await this.contract.getVariantsOfStep(i);
            let title;
            let id;
            for (let j = 0; j < variants[i].length; j++) {
                title = toAscii(resultList[0][j]);
                id = resultList[1][j];
                id.should.bignumber.equal(1 << (j + 1));
                variants[i][j].should.be.equal(title);
            }
        }
    });

});
