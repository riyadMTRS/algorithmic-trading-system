class Settings:
    # Data configuration
    DATA_PATH = "data/historical/"
    LIVE_DATA_BUFFER = 1000
    
    # Execution parameters
    SLIPPAGE = 0.0005  # 0.05%
    COMMISSION = 0.0002  # 0.02%
    
    # Risk management
    MAX_DRAWDOWN = 2.0  # %
    DAILY_LOSS_LIMIT = 5.0  # %

    # Strategy defaults
    DEFAULT_TIMEFRAME = "1h"
    ENABLED_STRATEGIES = ["SMC", "ICT", "Arbitrage"]
    
settings = Settings()
