pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

contract CalculatorMemory{

    struct Operation{
        string operation;
        int x;
        int y;
        int result;
    }

    // здесь храним историю операций для каждого адреса своя история
    Operation[] history;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
    }

    function addition(int x, int y) public returns (Operation){
        tvm.accept();
        history.push(Operation("addition", x, y, x + y));
        return history[history.length - 1];
    }

    function subtraction(int x, int y) public returns (Operation){
        tvm.accept();
        history.push(Operation("subtraction", x, y, x - y));
        return history[history.length - 1];
    }

    function multiplication(int x, int y) public returns (Operation){
        tvm.accept();
        history.push(Operation("multiplication", x, y, x * y));
        return history[history.length - 1];
    }

    function division(int x, int y)  public returns (Operation){
        tvm.accept();
        history.push(Operation("division", x, y, x / y));
        return history[history.length - 1];
    }

    function getOperationByIndex(uint index) public view returns(Operation){
        if( history.length > index ) {
            return history[index];
        }
        Operation empty;
        return empty;
    }

    function getLastOperation() public view returns(Operation){
        if( history.length > 0 ) {
            return history[history.length - 1];
        }
        Operation empty;
        return empty;
    }
}
