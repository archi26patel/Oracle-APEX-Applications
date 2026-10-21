create or replace PACKAGE PKG_OIL_MILL_CALCULATOR AS

    /* ==========================================
       1: KHAL COST
       ========================================== */
    PROCEDURE P_CALCULATE_KHAL_PARITY (
        P_SEED_RATE               IN NUMBER,
        P_SEED_BUY_UNIT           IN NUMBER,
        P_OIL_RATE                IN NUMBER,
        P_OIL_SELL_UNIT           IN NUMBER,
        P_PROCESSING_EXPENSE      IN NUMBER,
        P_EXPENSE_UNIT            IN NUMBER,
        P_OIL_PERCENT             IN NUMBER,
        P_CAKE_PERCENT            IN NUMBER,
        P_SHOW_COST_PER           IN VARCHAR2,

        P_KHAL_COST_OF_PRODUCTION OUT NUMBER
    );


    /* ==========================================
       2: PROFIT / CRUSHING P&L
       ========================================== */
    PROCEDURE P_CALCULATE_CRUSHING_PL (
        P_SEED_RATE          IN NUMBER,
        P_SEED_BUY_UNIT      IN NUMBER,
        P_OIL_RATE           IN NUMBER,
        P_OIL_SELL_UNIT      IN NUMBER,
        P_CAKE_RATE          IN NUMBER,
        P_CAKE_SELL_UNIT     IN NUMBER,
        P_PROCESSING_EXPENSE IN NUMBER,
        P_EXPENSE_UNIT       IN NUMBER,
        P_OIL_PERCENT        IN NUMBER,
        P_CAKE_PERCENT       IN NUMBER,

        P_NET_PROFIT_LOSS    OUT NUMBER
    );


    /* ==========================================
       3: OIL MILL RECOVERY
       ========================================== */
    PROCEDURE P_CALCULATE_OIL_RECOVERY (
        P_INPUT_SEED_KG  IN NUMBER,
        P_OIL_PERCENT    IN NUMBER,
        P_CAKE_PERCENT   IN NUMBER,

        P_OIL_YIELD_KG   OUT NUMBER,
        P_OIL_YIELD_PCT  OUT NUMBER,
        P_CAKE_YIELD_KG  OUT NUMBER,
        P_CAKE_YIELD_PCT OUT NUMBER,
        P_WASTE_YIELD_KG OUT NUMBER,
        P_WASTE_YIELD_PCT OUT NUMBER
    );




    /* ==========================================
       1: KHAL COST (FUNCTION)
       ========================================== */
    FUNCTION CALCULATE_KHAL_PARITY (
        P_SEED_RATE               IN NUMBER,
        P_SEED_BUY_UNIT           IN NUMBER,
        P_OIL_RATE                IN NUMBER,
        P_OIL_SELL_UNIT           IN NUMBER,
        P_PROCESSING_EXPENSE      IN NUMBER,
        P_EXPENSE_UNIT            IN NUMBER,
        P_OIL_PERCENT             IN NUMBER,
        P_CAKE_PERCENT            IN NUMBER,
        P_SHOW_COST_PER           IN VARCHAR2
    ) RETURN VARCHAR2;


    /* ==========================================
       2: PROFIT / CRUSHING P&L (FUNCTION)
       ========================================== */
    FUNCTION CALCULATE_CRUSHING_PL (
        P_SEED_RATE          IN NUMBER,
        P_SEED_BUY_UNIT      IN NUMBER,
        P_OIL_RATE           IN NUMBER,
        P_OIL_SELL_UNIT      IN NUMBER,
        P_CAKE_RATE          IN NUMBER,
        P_CAKE_SELL_UNIT     IN NUMBER,
        P_PROCESSING_EXPENSE IN NUMBER,
        P_EXPENSE_UNIT       IN NUMBER,
        P_OIL_PERCENT        IN NUMBER,
        P_CAKE_PERCENT       IN NUMBER
    ) RETURN VARCHAR2;


    /* ==========================================
       3: OIL MILL RECOVERY (FUNCTION)
       P_RETURN_TYPE accepts: OIL_KG, OIL_PCT, CAKE_KG, CAKE_PCT, WASTE_KG, WASTE_PCT
       ========================================== */
    FUNCTION CALCULATE_OIL_RECOVERY (
        P_INPUT_SEED_KG  IN NUMBER,
        P_OIL_PERCENT    IN NUMBER,
        P_CAKE_PERCENT   IN NUMBER,
        P_RETURN_TYPE    IN VARCHAR2
    ) RETURN VARCHAR2;

END PKG_OIL_MILL_CALCULATOR;
/