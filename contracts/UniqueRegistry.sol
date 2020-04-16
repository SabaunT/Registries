pragma solidity 0.5.8;

/**
 * This is another type of data organisation which 
 * distinctive feature is making links to record by it's
 * attributes. So, this makes easier to retrieve data with various ways.
 * But one of constraints is that data (attributes!) should be `unique`.
 *
 *
 * This type of data organisation was successfully implemented by smartz.io
 * https://github.com/smartzplatform/constructor-eth-registry/blob/master/contracts/Registry.sol
 * It is very convenient to use it with strings and bytes as they did in their contract.
 */

 contract Registry {

    struct UniqueData {
        uint256 row1; //attribute values
        bytes32 row2;
    }

    UniqueData[] public dataStorage;
    mapping(uint256 => uint256) row1Mapping; //save index of UniqueData record by attribute value
    mapping(bytes32 => uint256) row2Mapping;

    constructor() public {
        /**
         * Crucial stuff: 0 index is for "empty" values
         */
        dataStorage.push(UniqueData(0, ""));
    }

    function addData(uint256 _row1, bytes32 _row2) public returns (uint256) {
        require(findIDByRow1Value(_row1) == 0, "there is already a record with that data");
        //require(findIDByRow2Value(_row2) == 0, "sadasdasd");

        dataStorage.push(UniqueData({row1: _row1, row2: _row2}));
        row1Mapping[_row1] = dataStorage.length - 1;
        //the same for all the rows.

        return dataStorage.length - 1;
    }

    function findByRow1(uint256 _row1Value) public view returns (uint256, bytes32) {
        /// But writing (adding) to storage (records) would be cheaper with memory initialization according to
        /// https://medium.com/coinmonks/ethereum-solidity-memory-vs-storage-which-to-use-in-local-functions-72b593c3703a
        UniqueData storage uniqueRecord = dataStorage[findIDByRow1Value(_row1Value)]; 
        return (uniqueRecord.row1, uniqueRecord.row2);
    }

    function findIDByRow1Value(uint256 _row1Value) internal view returns (uint256) {
        return row1Mapping[_row1Value];
    }

    /// Should be done the same for row2 and all the rows.
}
