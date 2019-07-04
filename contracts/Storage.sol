pragma solidity 0.5.8;

/**
 * This type of data organisation look like in SQL type tables.
 * This "pattern" of data organisation is useful when you store data
 * about different objects. It is like storing into a class it's attributes.
 * As a result, storage contains of classes/instances/objects.
 *
 *
 * For this particular example address was chose as a "pk" unique variable,
 * while 'index' is used for indexing/searching/deleting easily.
 * 
 * This code does not require "owner" checks and so on.
 */
contract ObjectStorage {

    struct ObjectAttributeSchema {
        uint256 row1; //attributes
        uint256 row2;
        bool row3;

        uint256 index;
    }

    mapping(address => ObjectAttributeSchema) objectRecordsInStorage; //storage for attributes
    address[] objectIndexes; //store addresses by index, used to ease CRUD operations
    
    /* Could be added
    event StorageUpdates(address pk, uint256 index, bytes32 row1, uint256 row2, bool row3);
    event StorageInsert(address pk, uint256 index, bytes32 row1, uint256 row2, bool row3);
    */
    
    function insertInstance(uint256 _row1, uint256 _row2, bool _row3) public returns (uint256) {
        if (isInstance(msg.sender)) {
            revert("Instance is already in storage");
        }

        objectRecordsInStorage[msg.sender] = ObjectAttributeSchema(
            _row1,
            _row2,
            _row3,
            objectIndexes.push(msg.sender) - 1
        );
        
        //emit StorageInsert
        return objectIndexes.length;
    }

    //for any attribute in object schema
    function updateInstance(uint256 _row1) public {
        if (!isInstance(msg.sender)) {
            revert("There are no instances");
        }
        
        objectRecordsInStorage[msg.sender].row1 = _row1;
        //emit StorageUpdate;
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