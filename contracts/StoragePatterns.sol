pragma solidity 0.5.8;


/**
 * These are patterns of data organisation, that could be treated as
 * universal for variety of tasks.
 *
 *
 * Each of them will be described with its pros and cons.
 *
 */


contract SimpleArrayStorage {
    /**
     * This is the simplest example. But its functionality is very limited.
     * You can't control duplicates. What's more you can't get a random access to
     * the record without id knowledge.
     */
     
    struct RecordAttributes {
        uint256 row1;
        uint256 row2;
        address identifier;
    }

    RecordAttributes[] public recordsList;

    function newOne(uint256 _row1, uint256 _row2, address _id) public returns(uint256) {
        RecordAttributes memory newRecord = RecordAttributes(_row1, _row2, _id);
        return recordsList.push(newRecord)-1;
    }

    function count() public view returns (uint256) {
        return recordsList.length;
    }
}

contract SimpleMappingStorage {
    /**
     * This type of data organisation is better:
     * it ensures uniqueness, gives an opportunity to
     * find data without a knowledge of id. 
     *
     * But you can't enumerate or count keys.
     */

    struct RecordAttributes {
        uint256 row1;
        bool isEntity;
    }

    mapping (address => RecordAttributes) public recordsMapping;

    function isEntity(address _addr) public view returns (bool) {
        return recordsMapping[_addr].isEntity;
    }

    function newEntity(uint256 _row1, address _addr) public returns (bool) {
        require(!isEntity(_addr), "there is already such entity");
        recordsMapping[_addr].row1 = _row1;
        recordsMapping[_addr].isEntity = true;
        return recordsMapping[_addr].isEntity;
    }

    function deleteEntity(address _addr) public {
        require(isEntity(_addr), "there is no such entity");
        recordsMapping[_addr].isEntity = false;
    }

    function updateEntity(address _addr, uint256 _row1) public returns(bool) {
        require(isEntity(_addr), "there is no such entity");
        recordsMapping[_addr].row1 = _row1;
        return true;
    }
}

contract UniqueArrayOfStructs is SimpleArrayStorage {
    /**
     * This is a more complex example of array storage.
     * The difference is that we add mapping to track records uniqeness.
     *
     * But you still need an ID to access and update data.
     */

    mapping (address => bool) knownRecord;

    function isRecord(address _addr) public view returns (bool) {
        return knownRecord[_addr];
    }

    ///override
    function newOne(uint256 _row1, uint256 _row2, address _id) public returns(uint256) {
        require(!isRecord(_id));
        RecordAttributes memory newRecord = RecordAttributes(_row1, _row2, _id);
        knownRecord[_id] = true;
        return recordsList.push(newRecord) - 1;
    }
}

contract MappingStorageWithId is SimpleMappingStorage {
    /**
     * This type solved all the problems of SimpleMappingStorgae and inherited
     * all its pros. But there is still a problem with an uncontrolled `entityList` growth.
     * A more complex variant is a `BaseObjectStorage.sol`.
     */

    address[] public entityList;

    function count() public view returns (uint256) {
        return entityList.length;
    }

    ///override
    function newEntity(address _addr, uint256 _row1) public returns (uint256) {
        require(!isEntity(_addr), "there is already such entity");
        recordsMapping[_addr].row1 = _row1;
        recordsMapping[_addr].isEntity = true;
        return entityList.push(_addr) - 1;
    }
}