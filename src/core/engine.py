class TradingEngine:
    """Core execution engine"""
    
    def __init__(self, broker, risk_manager):
        self.broker = broker
        self.risk_manager = risk_manager
        self.strategies = {}
        self.performance_tracker = PerformanceTracker()
        
    def add_strategy(self, strategy_class, config):
        strategy = strategy_class(
            data_handler=self.broker.get_feed(),
            executor=self.broker.get_executor(),
            risk_model=self.risk_manager
        )
        self.strategies[strategy.name] = strategy
        
    def run(self):
        while True:
            tick = self.broker.get_next_tick()
            self.process_tick(tick)
            
    def process_tick(self, tick):
        for strategy in self.strategies.values():
            if strategy.should_analyze(tick):
                signal = strategy.analyze(tick)
                if signal and self.risk_manager.approve(signal):
                    self.execute_signal(signal)
