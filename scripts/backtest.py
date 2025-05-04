def main():
    config = load_config()
    data = load_historical_data(config.DATA_PATH)
    
    cerebro = bt.Cerebro()
    cerebro.adddata(data)
    
    # Add strategies
    for strategy in config.ENABLED_STRATEGIES:
        cerebro.addstrategy(get_strategy_class(strategy))
        
    # Run backtest
    results = cerebro.run()
    
    # Generate report
    generate_report(
        results,
        metrics=['sharpe', 'drawdown', 'win_rate']
    )

if __name__ == "__main__":
    main()
