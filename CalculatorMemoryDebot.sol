pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

// Подключение библиотек и интерфейсов дебота
import "dLibraries/Debot.sol";
import "dInterfaces/Terminal.sol";
import "dInterfaces/NumberInput.sol";
import "dInterfaces/Menu.sol";

// Подключение интерфейса контракта
import "cInterfaces/ICalculatorMemory.sol";

contract CalculatorMemoryDebot is Debot {

    address addrCalculator;
    uint32 idOperation;
    int x;

    constructor(address _addrCalculator) public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
        addrCalculator = _addrCalculator;
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Calculator Debot";
        version = "0.0.1";
        publisher = "MSHP";
        key = "";
        author = "Kirill Zaynutdinov";
        support = address.makeAddrStd(0, 0x0);
        hello = "Hello, I'm CalculatorMemoryDeBot";
        language = "en";
        dabi = m_debotAbi.get();
        icon = "";
    }

    // интерфейсы дебота
    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [
            NumberInput.ID,
            Menu.ID,
            Terminal.ID
        ];
    }

    function setCalculatorAddress(address _addrCalculator) public {
        tvm.accept();
        addrCalculator = _addrCalculator;
    }

    // Начало работы дебота
    function start() public override {
        // Вызов функции mainMenu()
        mainMenu();
    }

    function mainMenu() public {

        // Выводим меню
        Menu.select("==What to do?==", "", 
        [
            MenuItem("Addition", "", tvm.functionId(setOperation)),
            MenuItem("Subtraction", "", tvm.functionId(setOperation)),
            MenuItem("Multiplication", "", tvm.functionId(setOperation)),
            MenuItem("Division", "", tvm.functionId(setOperation)),
            MenuItem("Get operation by index", "", tvm.functionId(inputIndex)),
            MenuItem("Get last operation", "", tvm.functionId(getLastOperation)),
            MenuItem("Exit", "", tvm.functionId(exit))
        ]);
    }

    // В эту функцию передаётся индекс выбранного нами пункта меню
    function setOperation(uint32 index) public {
        Terminal.print(0, format("Chosen: {}", index));
        // В зависимости от введёного значения записывает в idOperation
        // Id одной из четырёх функций: addition(), subtraction(), multiplication(), division()
        if ( index == 0 ) {
            idOperation = tvm.functionId(addition);
        } else if ( index == 1 ) {
            idOperation = tvm.functionId(subtraction);
        } else if ( index == 2 ) {
            idOperation = tvm.functionId(multiplication);
        } else if ( index == 3 ){
            idOperation = tvm.functionId(division);
        } 
        // NumberInput.get() - принимает значение, вызывает функцию setX и передаёт ей это значение в качестве аргумента
        NumberInput.get(tvm.functionId(setX), "input first number:", -1000000, 1000000);
    }

    // setX() функция сохраняет полученное значение в х
    // B ещё раз считывает значение и вызывает функцию idOperation(), передавая ей это значение
    function setX(int value) public {
        x = value;
        NumberInput.get(idOperation, "input second number:", -1000000, 1000000);
    }

    // В зависимости от того, Id какой функции было сохранено idOperation запускается одна из этих функций
    // функции addition(), subtraction(), multiplication(), division() возвращают структуру типа Operation
    // эту структуру они передают в функцию printResult()

    function addition(int value) public view {
        optional(uint256) pubkey = 0;
        ICalculatorMemory(addrCalculator).addition{
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function subtraction(int value) public view {
        optional(uint256) pubkey = 0;
        ICalculatorMemory(addrCalculator).subtraction{
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function multiplication(int value) public view {
        optional(uint256) pubkey = 0;
        ICalculatorMemory(addrCalculator).multiplication{
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function division(int value) public view {
        optional(uint256) pubkey = 0;
        ICalculatorMemory(addrCalculator).division{
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    // вводим индекс
    function inputIndex(uint32 index)public {
        index;
        NumberInput.get(tvm.functionId(getOperationByIndex), "input operation index:", 0, 1000000);
    }

    // получение операции по индексу
    function getOperationByIndex(uint value)public view  {
        optional(uint256) none;
        ICalculatorMemory(addrCalculator).getOperationByIndex{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(value).extMsg;
    }

    // получение последней операции
    function getLastOperation(uint32 index)public view  {
        index;
        optional(uint256) none;
        ICalculatorMemory(addrCalculator).getLastOperation{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }().extMsg;
    }

    // Вывод результата
    function printResult(Operation result) public {
        Terminal.print(0, format("Operation: {}({}, {}) = {}",
            result.operation,
            result.x,
            result.y,
            result.result
        ));
        mainMenu();
    }

    // выход из дебота
    function exit(uint32 index)public view{
        index;
        Terminal.print(0, "Goodbay!");
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
    }
}
