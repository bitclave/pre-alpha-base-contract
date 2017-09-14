'use strict';
const BaseContract = artifacts.require("BaseContract");

contract('BaseContract', function (accounts) {

        beforeEach(async function () {
                this.token = await BaseContract.new();

                this.rootCategory = fromAscii("car", 32);

                this.category = [
                        fromAscii("mark", 32),
                        fromAscii("model", 32),
                        fromAscii("year", 32),
                        fromAscii("new", 32)];

                this.categoryValues = [
                        fromAscii("toyota", 32),
                        fromAscii("rav4", 32),
                        fromAscii("2017", 32),
                        fromAscii("true", 32)];

                this.rulesKeys = [
                        fromAscii("salary", 32),
                        fromAscii("age", 32),
                        fromAscii("USA", 32),
                        fromAscii("car", 32)];

                this.rulesValues = [
                        fromAscii("3000", 32),
                        fromAscii("32", 32),
                        fromAscii("USA", 32),
                        fromAscii("car", 32)];
        });

        it('create advert and validate set data', async function(){

                let rulesActions = [5, 3, 0, 0]; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.

                let rulesWorth = [60, 20, 10, 10];

                await this.token.createAdvertInCatalog(
                        this.rootCategory,
                        this.category,
                        this.categoryValues,
                        "http://www.toyota-global.com/",
                        "this is crossover of toyota motors. Best of the best!? =)",
                        "https://goo.gl/CLmzaC",
                        100,
                        2000,
                        this.rulesKeys,
                        this.rulesValues,
                        rulesActions,
                        rulesWorth
                );

                rulesActions = [3, 3, 1, 5]; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.
                await this.token.createAdvertInCatalog(
                        this.rootCategory,
                        this.category,
                        this.categoryValues,
                        "http://www.toyota-global.com/",
                        "this is crossover of toyota motors. Best of the best!? =)",
                        "https://goo.gl/CLmzaC",
                        100,
                        2000,
                        this.rulesKeys,
                        this.rulesValues,
                        rulesActions,
                        rulesWorth
                );

                rulesActions = [5, 3, 0, 0]; //0 - '=='; 1 - '!='; 2 - '<='; 3 - '>='; 4 - '>'; 5 - '<'.

                await this.token.createAdvertInCatalog(
                        this.rootCategory,
                        this.category,
                        this.categoryValues,
                        "http://www.toyota-global.com/",
                        "this is crossover of toyota motors. Best of the best!? =)",
                        "https://goo.gl/CLmzaC",
                        100,
                        2000,
                        this.rulesKeys,
                        this.rulesValues,
                        rulesActions,
                        rulesWorth
                );

                rulesActions = [3, 3, 0, 0];
                await this.token.createAdvertInCatalog(
                        fromAscii("home", 32),
                        [fromAscii("city", 32)],
                        [fromAscii("somevalue", 32)],
                        "http://www.toyota-global.com/",
                        "this is crossover of toyota motors. Best of the best!? =)",
                        "https://goo.gl/CLmzaC",
                        100,
                        2000,
                        this.rulesKeys,
                        this.rulesValues,
                        rulesActions,
                        rulesWorth
                );

                let resultAdvert = await this.token.getAdvert.call(1);
                console.log(resultAdvert);

                let arrayKeys = await this.token.getClientInfoFields.call();
                console.log("getClientInfoFields:");
                printBytes32Array(arrayKeys);
                assert.equal(arrayKeys.length, 4, "incorrect count of user fields");
                assert.equal(arrayKeys[0], this.rulesKeys[0], "incorrect user field index 0");
                assert.equal(arrayKeys[1], this.rulesKeys[1], "incorrect user field index 1");
                assert.equal(arrayKeys[2], this.rulesKeys[2], "incorrect user field index 2");
                assert.equal(arrayKeys[3], this.rulesKeys[3], "incorrect user field index 3");

                await this.token.saveUserInfo(
                        this.rulesKeys, this.rulesValues);

                let result = await this.token.searchAdvert(
                        this.rootCategory,
                        this.category,
                        this.categoryValues
                );

                result = await this.token.searchAdvert.call( //without save. only for get result
                        this.rootCategory,
                        this.category,
                        this.categoryValues
                );
                assert.equal(result.length, 1, "incorrect count of searched AD");
                assert.equal(result[0], 2, "incorrect AD id");

                let advertTypes = await this.token.getAdvertTypes.call();
                console.log("getAdvertTypes:");
                printBytes32Array(advertTypes);
                assert.equal(advertTypes.length, 2, "incorrect count of advert type");
                assert.equal(advertTypes[0], this.rootCategory, "incorrect advert type index 0");
                assert.equal(advertTypes[1], fromAscii("home", 32) , "incorrect advert type index 1");

                let advertSubCategory = await this.token.getSubCategories.call(this.rootCategory);
                console.log("advertSubCategory:");
                printBytes32Array(advertSubCategory);
                assert.equal(advertSubCategory.length, this.category.length, "incorrect count of sub categories");
                for(let i = 0; i < this.category.length; i++) {
                        assert.equal(advertSubCategory[i], this.category[i], "incorrect subcategories index " + i);
                }

                let reward = await this.token.transferUserRewards.call(2); //2 - active advert id
                console.log("rewards:", reward);
                assert.equal(reward, 1600, "incorrect rewards for client"); //1600 = 80% from 2000
        });

        let fromAscii = function (str, padding) {
                let result = web3.fromAscii(str, padding);
                //web3.fromAscii(str, pading); - incorrect work and not add padding;
                return result + "0".repeat(padding * 2 - result.length + 2);
        };

        let printBytes32Array = function (bytes32array) {
                let len = bytes32array.length;
                console.log("--------start --------");
                for (let i = 0; i < len; i++) {
                        console.log(web3.toAscii(bytes32array[i]));
                }
                console.log("--------finish --------");
        };
});
