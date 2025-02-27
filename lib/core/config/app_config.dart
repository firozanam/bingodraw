class AppConfig {
  static const String appName = 'Lottery';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.example.com'; // Replace with actual API URL
  static const int ticketQuota = 100; // Number of tickets needed for a draw
  static const double ticketPrice = 10.0; // USDT
  
  // Binance Smart Chain settings
  static const String binanceNetwork = 'testnet'; // 'mainnet' or 'testnet'
  static const String usdtContractAddress = '0x337610d27c682E347C9cD60BD4b3b107C9d34dDd'; // BSC Testnet USDT
  static const String adminWalletAddress = '0x123...'; // Replace with actual admin wallet
  
  // Network RPC URLs
  static const String bscMainnetRpc = 'https://bsc-dataseed.binance.org/';
  static const String bscTestnetRpc = 'https://data-seed-prebsc-1-s1.binance.org:8545/';
  
  // Block Explorer URLs
  static const String bscMainnetExplorer = 'https://bscscan.com';
  static const String bscTestnetExplorer = 'https://testnet.bscscan.com';

  // Smart Contract ABIs
  static const String usdtAbi = '''
    [
      {
        "constant": true,
        "inputs": [{"name": "_owner","type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "balance","type": "uint256"}],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "_to","type": "address"},
          {"name": "_value","type": "uint256"}
        ],
        "name": "transfer",
        "outputs": [{"name": "success","type": "bool"}],
        "type": "function"
      }
    ]
  ''';

  // Utility getters
  static String get rpcUrl => binanceNetwork == 'mainnet' ? bscMainnetRpc : bscTestnetRpc;
  static String get explorerUrl => binanceNetwork == 'mainnet' ? bscMainnetExplorer : bscTestnetExplorer;

  // Cache Configuration
  static const int cacheValidityDuration = 24 * 60 * 60; // 24 hours in seconds
}