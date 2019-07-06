pragma solidity 0.5.8;


/**
 * Mr. Rob Hitchens who inspired me by his great articles
 * to create this repo, had a brilliant idea on how to 
 * organise data with classic db principes.
 * It is shown here how to make one-to-many relations data organisation.
 *
 *
 * That looks more scientific than practical.
 */


contract OneToMany {
    
    struct OneStruct {
        uint256 oneListPointer; 
        // One has many "Many"
        bytes32[] manyIds; 
        mapping(bytes32 => uint256) manyIdPointers;

        /// more app data
    }
    
    mapping(bytes32 => OneStruct) public oneStructs;
    bytes32[] public oneList;
    
    // other entity is called a "Many"
    
    struct ManyStruct {
        // needed to delete a "Many"
        uint256 manyListPointer; 
        // many has exactly one "One"
        bytes32 oneId;
        
        /// add app fields
    }
    
    mapping(bytes32 => ManyStruct) public manyStructs;
    bytes32[] public manyList;
    
    function getOneCount()  public view returns(uint256 oneCount) {return oneList.length;}
    function getManyCount() public view returns(uint256 manyCount){return manyList.length;}
    
    function isOne(bytes32 oneId) public view returns(bool isIndeed) {
        if(oneList.length==0) return false;
        return oneList[oneStructs[oneId].oneListPointer]==oneId;
    }
    
    function isMany(bytes32 manyId) public view returns(bool isIndeed) {
        if(manyList.length==0) return false;
        return manyList[manyStructs[manyId].manyListPointer]==manyId;
    }
    
    // Iterate over a One's Many keys
    
    function getOneManyIdCount(bytes32 oneId) public view returns(uint256 manyCount) {
        if(!isOne(oneId)) revert();
        return oneStructs[oneId].manyIds.length;
    }
    
    function getOneManyIdAtIndex(bytes32 oneId, uint256 rowIndex) public view returns(bytes32 manyKey) {
        if(!isOne(oneId)) revert();
        return oneStructs[oneId].manyIds[rowIndex];
    }
    
    // Insert
    
    function createOne(bytes32 oneId) public returns(bool success) {
        if(isOne(oneId)) revert(); // duplicate key prohibited
        oneStructs[oneId].oneListPointer = oneList.push(oneId)-1;
        return true;
    }
    
    function createMany(bytes32 manyId, bytes32 oneId) public returns(bool success) {
        if(!isOne(oneId)) revert();
        if(isMany(manyId)) revert(); // duplicate key prohibited
        manyStructs[manyId].manyListPointer = manyList.push(manyId)-1;
        manyStructs[manyId].oneId = oneId; // each many has exactly one "One", so this is mandatory
        // We also maintain a list of "Many" that refer to the "One", so ... 
        oneStructs[oneId].manyIdPointers[manyId] = oneStructs[oneId].manyIds.push(manyId) - 1;
        return true;
    }
    
    // Delete
    
    function deleteOne(bytes32 oneId) public returns(bool succes) {
        if(!isOne(oneId)) revert();
        if(oneStructs[oneId].manyIds.length>0) revert(); // this would break referential integrity
        uint256 rowToDelete = oneStructs[oneId].oneListPointer;
        bytes32 keyToMove = oneList[oneList.length-1];
        oneList[rowToDelete] = keyToMove;
        oneStructs[keyToMove].oneListPointer = rowToDelete;
        oneList.length--;
        return true;
    }    
    
    function deleteMany(bytes32 manyId) public returns(bool success) {
        if(!isMany(manyId)) revert(); // non-existant key
        
        // delete from the Many table
        uint256 rowToDelete = manyStructs[manyId].manyListPointer;
        bytes32 keyToMove = manyList[manyList.length-1];
        manyList[rowToDelete] = keyToMove;
        manyStructs[manyId].manyListPointer = rowToDelete;
        manyList.length--;
        
        // we ALSO have to delete this key from the list in the ONE that was joined to this Many
        bytes32 oneId = manyStructs[manyId].oneId; // it's still there, just not dropped from index
        rowToDelete = oneStructs[oneId].manyIdPointers[manyId];
        keyToMove = oneStructs[oneId].manyIds[oneStructs[oneId].manyIds.length-1];
        oneStructs[oneId].manyIds[rowToDelete] = keyToMove;
        oneStructs[oneId].manyIdPointers[keyToMove] = rowToDelete;
        oneStructs[oneId].manyIds.length--;
        return true;
    }
}