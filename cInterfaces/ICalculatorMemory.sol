pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

struct Operation{
    string operation;
    int x;
    int y;
    int result;
}

interface ICalculatorMemory {
    function addition (int x, int y) external returns (Operation);
    function subtraction (int x, int y) external returns (Operation);
    function multiplication (int x, int y) external returns (Operation);
    function division (int x, int y) external returns (Operation);
    function getOperationByIndex(uint index) external view returns(Operation);
    function getLastOperation() external view returns(Operation);
}
