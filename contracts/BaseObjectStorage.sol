pragma solidity 0.5.8;

/**
 * This type of data organisation look like in SQL type tables.
 * This "pattern" of data organisation is useful when you store data
 * about different objects. It is like storing into a class it's attributes.
 * As a result, storage contains of classes/instances/objects.
 *
 *
 * For this particular example address was chose as a "pk" unique variable,
 * while 'index' is used for easy referencing.
 * 
 * This code does not require "owner" checks and so on.
 * Library implementation: https://github.com/rob-Hitchens/UnorderedKeySet <- more convenient
 */
contract BaseObjectStorage {

    struct ObjectAttributeSchema {
        uint256 row1; //attributes
        uint256 row2;
        bool row3;

        uint256 index;
    }

    mapping(address => ObjectAttributeSchema) private objectRecordsInStorage; //storage for attributes
    address[] objectIndexes; //store addresses by index, used to ease CRUD operations
    
    /* Could be added
    event StorageUpdates(address pk, uint256 index, bytes32 row1, uint256 row2, bool row3);
    event StorageInsert(address pk, uint256 index, bytes32 row1, uint256 row2, bool row3);
    */
    
    function insertInstance(address _inst, uint256 _row1, uint256 _row2, bool _row3) public returns (uint256) {
        if (isInstance(_inst)) {
            revert("Instance is already in storage");
        }

        objectRecordsInStorage[_inst] = ObjectAttributeSchema(
            _row1,
            _row2,
            _row3,
            objectIndexes.push(_inst) - 1
        );
        
        //emit StorageInsert
        return objectIndexes.length;
    }

    //for any attribute in object schema
    function updateInstance(address _inst, uint256 _row1) public {
        if (!isInstance(_inst)) {
            revert("There are no instances");
        }
        
        objectRecordsInStorage[_inst].row1 = _row1;
        //emit StorageUpdate;
    }

    // pureness of this type of storage organisation is that 
    // you don't have to `delete` items in mapping
    function deleteInstanceRecords(address _inst) public returns (uint256) {
        if (!isInstance(_inst)) {
            revert("no such record");
        }

        uint256 deletingIndex = objectRecordsInStorage[_inst].index;
        address movingToDeletedPositionKey = objectIndexes[objectIndexes.length - 1];

        objectIndexes[deletingIndex] = movingToDeletedPositionKey;
        objectRecordsInStorage[movingToDeletedPositionKey].index = deletingIndex;
        
        // Now an object is considered to be deleted, because it won't pass `isInstance`
        // however it is still in mapping
        objectIndexes.pop();
    }

    function getInstance(address instanceAddress) public view returns (uint256, uint256, bool) {
        if (!isInstance(instanceAddress)) {
            revert("There are no such instances");
        }

        ObjectAttributeSchema memory referenceVariable = objectRecordsInStorage[instanceAddress];
        return (
            referenceVariable.row1,
            referenceVariable.row2,
            referenceVariable.row3
        );
    }

    function getInstancePKAtIndex(uint256 index) public view returns (address) {
        return objectIndexes[index];
    }
    
    function isInstance(address _instance) internal view returns (bool) {
        if (objectIndexes.length == 0) {
            return false;
        }
        return (objectIndexes[objectRecordsInStorage[_instance].index] == _instance);
    }
}