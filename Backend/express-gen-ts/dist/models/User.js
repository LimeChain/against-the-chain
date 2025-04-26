"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const jet_validators_1 = require("jet-validators");
const utils_1 = require("jet-validators/utils");
const validators_1 = require("@src/common/util/validators");
const DEFAULT_USER_VALS = () => ({
    id: -1,
    name: '',
    created: new Date(),
    email: '',
});
const parseUser = (0, utils_1.parseObject)({
    id: validators_1.isRelationalKey,
    name: jet_validators_1.isString,
    email: jet_validators_1.isString,
    created: validators_1.transIsDate,
});
function newUser(user) {
    const retVal = { ...DEFAULT_USER_VALS(), ...user };
    return parseUser(retVal, errors => {
        throw new Error('Setup new user failed ' + JSON.stringify(errors, null, 2));
    });
}
function testUser(arg, errCb) {
    return !!parseUser(arg, errCb);
}
exports.default = {
    new: newUser,
    test: testUser,
};
