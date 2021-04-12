pragma solidity >=0.4.25 <0.7.0;

contract BigFlexToken {
    string internal _name;
    string internal _symbol;
    uint256 internal _granularity;
    uint256 internal _totalSupply = 0;

    mapping(address => uint256) internal _balances;
    mapping(address => bool) internal _isDefaultOperator;
    mapping(address => mapping(address => bool)) internal _isAuthOperator;
    mapping(address => mapping(address => bool)) internal _isRevokedOperator;
    address[] internal _defaultOperators;

    constructor(string memory name, string memory symbol, uint256 initSupply, uint256 granularity, address[] memory defaultOperators) public {
        _name = name;
        _symbol = symbol;
        // Минимально возможная часть токена (>=1)
        require(granularity >= 1, "Granularity must be >= 1");
        _granularity = granularity;

        // Количество токенов всегда должно быть кратно _granularity
        require(initSupply % _granularity == 0, "Err. The number of tokens must be a multiple of granularity");

        // Отдаем все токены создателю
        _totalSupply = initSupply;
        _balances[msg.sender] = _totalSupply;

        // Добавляем операторы по умолчанию,
        // эти адреса могут совершать транзакции от лица любого другого адреса
        _defaultOperators = defaultOperators;
        for (uint256 ind = 0; ind < _defaultOperators.length; ind++) {
            _isDefaultOperator[_defaultOperators[ind]] = true;
        }
    }

    // геттеры

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function granularity() external view returns (uint256) {
        return _granularity;
    }

    function balanceOf(address holder) external view returns (uint256) {
        return _balances[holder];
    }

    function defaultOperators() external view returns (address[] memory) {
        return _defaultOperators;
    }

    // Проверяет, является ли адрес operator оператором для holder
    function isOperatorFor(address operator, address holder) public view returns (bool) {
        return !_isRevokedOperator[holder][operator] && (_isDefaultOperator[operator] || _isAuthOperator[holder][operator]);
    }

    // Добавляет нового оператора для msg.sender
    function authorizeOperator(address operator) external {
        require(operator != msg.sender, "Err. You can't auth the holder");
        _isAuthOperator[msg.sender][operator] = true;
        _isRevokedOperator[msg.sender][operator] = false;
        emit AuthorizedOperator(operator, msg.sender);
    }
    // Удаляет оператора у msg.sender
    function revokeOperator(address operator) external {
        require(operator != msg.sender, "Err. You can't revoke the right to be operator for yourself");
        _isRevokedOperator[msg.sender][operator] = true;
        emit RevokedOperator(operator, msg.sender);
    }

    // Отправка токенов от адреса msg.sender
    function send(address to, uint256 amount, bytes calldata data) external {
        sendTokens(msg.sender, to, amount, data, data);
    }

    // Отправка токенов от адреса from через оператора
    function operatorSend(address from, address to, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, from),
        "Err. You aren't operator for this outgoing address");
        sendTokens(from, to, amount, data, operatorData);
    }
    event checkTokens(address, address, uint256, uint256);
    function sendTokens(address from, address to, uint256 amount, bytes memory data, bytes memory operatorData) internal {
        // Проверка адресов
        require(from != address(0), "Err. Sender's address can't be equal to 0");
        require(to != address(0), "Err. Recipient's address can't be equal to 0");
        emit checkTokens(from, to, amount, _balances[from]);
        // Проверка, достаточно ли токенов у отправителя
        require(amount <= _balances[from], "Err. You don't have enough tokens to send");

        // Количество отправляемых токенов должно быть кратно _granularity
        require(amount % _granularity == 0, "Err. The number of tokens to be sent must be a multiple of granularity");

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Sent(msg.sender, from, to, amount, data, operatorData);
    }

    // Уничтожение токенов у адреса msg.sender
    function burn(uint256 amount, bytes calldata data) external {
        burnTokens(msg.sender, amount, data, data);
    }

    // Уничтожение токенов у адреса from через оператора
    function operatorBurn(address from, uint256 amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, from),
        "Err. You aren't operator for this address");
        burnTokens(from, amount, data, operatorData);
    }

    function burnTokens(address from, uint256 amount, bytes memory data, bytes memory operatorData) internal {
        // Проверка адреса
        require(from != address(0), "Err. You can't burn tokens in address 0");

        // Проверка количества токенов на кратность
        require(amount % _granularity == 0, "Err. The number of tokens to be burned must be a multiple of granularity");

        // Проверка, достаточно ли токенов
        require(amount <= _balances[from], "Err. There isn't enough tokens to burn");

        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Burned(msg.sender, from, amount, data, operatorData);
    }

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
    event Burned(
        address indexed operator,
        address indexed from,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
    event AuthorizedOperator(
        address indexed operator,
        address indexed holder
    );
    event RevokedOperator(address indexed operator, address indexed holder);
}
