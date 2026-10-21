create or replace PACKAGE BODY PKG_OIL_MILL_CALCULATOR AS

    C_BATCH_KG CONSTANT NUMBER := 1000;


    /* ==================================================
       1: KHAL COST
       ================================================== */
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
    ) IS
        L_SEED_COST       NUMBER;
        L_PROCESS_COST    NUMBER;
        L_TOTAL_COST      NUMBER;
        L_OIL_YIELD_KG    NUMBER;
        L_CAKE_YIELD_KG   NUMBER;
        L_OIL_REVENUE     NUMBER;
        L_CAKE_COST_PER_KG NUMBER;
        L_SELECTED_KG     NUMBER;
    BEGIN
        P_KHAL_COST_OF_PRODUCTION := NULL;

        /* Required fields */
        IF P_SEED_RATE IS NULL
           OR P_SEED_BUY_UNIT IS NULL
           OR P_OIL_RATE IS NULL
           OR P_OIL_SELL_UNIT IS NULL
           OR P_PROCESSING_EXPENSE IS NULL
           OR P_EXPENSE_UNIT IS NULL
           OR P_OIL_PERCENT IS NULL
           OR P_CAKE_PERCENT IS NULL
           OR P_SHOW_COST_PER IS NULL
        THEN
            RAISE_APPLICATION_ERROR(-20001,'Khal Cost: All input fields are required.');
        END IF;

        /* Amount validation */
        IF P_SEED_RATE < 0
           OR P_OIL_RATE < 0
           OR P_PROCESSING_EXPENSE < 0
        THEN
            RAISE_APPLICATION_ERROR(-20002,'Rates and processing expense cannot be negative.');
        END IF;

        /* Unit validation */
        IF P_SEED_BUY_UNIT NOT IN (20, 100, 1000) THEN
            RAISE_APPLICATION_ERROR(-20003,'Invalid seed purchase unit.');
        END IF;

        IF P_EXPENSE_UNIT NOT IN (20, 100, 1000) THEN
            RAISE_APPLICATION_ERROR(-20004,'Invalid processing expense unit.');
        END IF;

        IF P_OIL_SELL_UNIT NOT IN (1, 10, 15) THEN
            RAISE_APPLICATION_ERROR(-20005,'Invalid oil selling unit.');
        END IF;

        /* Percentage validation */
        IF P_OIL_PERCENT <= 0 OR P_OIL_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20006,'Oil recovery must be greater than 0 and at most 100.');
        END IF;

        IF P_CAKE_PERCENT <= 0 OR P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20007,'Cake recovery must be greater than 0 and at most 100.');
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20008,'Oil and cake percentages cannot total more than 100.');
        END IF;

        /* Selected output unit */
        CASE UPPER(TRIM(P_SHOW_COST_PER))
            WHEN 'BAG'  THEN L_SELECTED_KG := 50;
            WHEN '20K'  THEN L_SELECTED_KG := 20;
            WHEN '100K' THEN L_SELECTED_KG := 100;
            WHEN '1K'   THEN L_SELECTED_KG := 1;
            ELSE
                RAISE_APPLICATION_ERROR(-20009,'Invalid Show Cost Per selection.');
        END CASE;

        /* Seed cost for 1000 kg */
        L_SEED_COST :=
            (C_BATCH_KG / P_SEED_BUY_UNIT) * P_SEED_RATE;

        /* Processing expense for 1000 kg */
        L_PROCESS_COST :=
            (C_BATCH_KG / P_EXPENSE_UNIT) * P_PROCESSING_EXPENSE;

        L_TOTAL_COST := L_SEED_COST + L_PROCESS_COST;

        /* Output quantities */
        L_OIL_YIELD_KG :=
            C_BATCH_KG * P_OIL_PERCENT / 100;

        L_CAKE_YIELD_KG :=
            C_BATCH_KG * P_CAKE_PERCENT / 100;

        IF L_CAKE_YIELD_KG <= 0 THEN
            RAISE_APPLICATION_ERROR(-20010,'Cake yield must be greater than zero.');
        END IF;

        /* Oil revenue */
        L_OIL_REVENUE :=
            (L_OIL_YIELD_KG / P_OIL_SELL_UNIT) * P_OIL_RATE;

        /* Remaining cost belongs to cake */
        L_CAKE_COST_PER_KG :=
            (L_TOTAL_COST - L_OIL_REVENUE) / L_CAKE_YIELD_KG;

        /* Final selected-unit cost */
        P_KHAL_COST_OF_PRODUCTION :=
            ROUND(L_CAKE_COST_PER_KG * L_SELECTED_KG, 2);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END P_CALCULATE_KHAL_PARITY;


    /* ==================================================
       2: PROFIT / CRUSHING P&L
       ================================================== */
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
    ) IS
        L_SEED_COST       NUMBER;
        L_PROCESS_COST    NUMBER;
        L_TOTAL_COST      NUMBER;
        L_OIL_YIELD_KG    NUMBER;
        L_CAKE_YIELD_KG   NUMBER;
        L_OIL_REVENUE     NUMBER;
        L_CAKE_REVENUE    NUMBER;
        L_TOTAL_REVENUE   NUMBER;
    BEGIN
        P_NET_PROFIT_LOSS := NULL;

        /* Required fields */
        IF P_SEED_RATE IS NULL
           OR P_SEED_BUY_UNIT IS NULL
           OR P_OIL_RATE IS NULL
           OR P_OIL_SELL_UNIT IS NULL
           OR P_CAKE_RATE IS NULL
           OR P_CAKE_SELL_UNIT IS NULL
           OR P_PROCESSING_EXPENSE IS NULL
           OR P_EXPENSE_UNIT IS NULL
           OR P_OIL_PERCENT IS NULL
           OR P_CAKE_PERCENT IS NULL
        THEN
            RAISE_APPLICATION_ERROR(-20011,'Crushing P&L: All input fields are required.');
        END IF;

        /* Amount validation */
        IF P_SEED_RATE < 0
           OR P_OIL_RATE < 0
           OR P_CAKE_RATE < 0
           OR P_PROCESSING_EXPENSE < 0
        THEN
            RAISE_APPLICATION_ERROR(-20012,'Rates and processing expense cannot be negative.');
        END IF;

        /* Unit validation */
        IF P_SEED_BUY_UNIT NOT IN (20, 100, 1000) THEN
            RAISE_APPLICATION_ERROR(-20013,'Invalid seed purchase unit.');
        END IF;

        IF P_EXPENSE_UNIT NOT IN (20, 100, 1000) THEN
            RAISE_APPLICATION_ERROR(-20014,'Invalid processing expense unit.');
        END IF;

        IF P_OIL_SELL_UNIT NOT IN (1, 10, 15) THEN
            RAISE_APPLICATION_ERROR(-20015,'Invalid oil selling unit.');
        END IF;

        IF P_CAKE_SELL_UNIT NOT IN (1, 20, 50, 100) THEN
            RAISE_APPLICATION_ERROR(-20016,'Invalid cake selling unit.');
        END IF;

        /* Percentage validation */
        IF P_OIL_PERCENT <= 0 OR P_OIL_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20017,'Oil percentage must be greater than 0 and at most 100.');
        END IF;

        IF P_CAKE_PERCENT <= 0 OR P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20018,'Cake percentage must be greater than 0 and at most 100.');
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20019,'Oil and cake percentages cannot total more than 100.');
        END IF;

        /* Cost for 1000 kg seed */
        L_SEED_COST :=
            (C_BATCH_KG / P_SEED_BUY_UNIT) * P_SEED_RATE;

        L_PROCESS_COST :=
            (C_BATCH_KG / P_EXPENSE_UNIT) * P_PROCESSING_EXPENSE;

        L_TOTAL_COST := L_SEED_COST + L_PROCESS_COST;

        /* Yield for 1000 kg seed */
        L_OIL_YIELD_KG :=
            C_BATCH_KG * P_OIL_PERCENT / 100;

        L_CAKE_YIELD_KG :=
            C_BATCH_KG * P_CAKE_PERCENT / 100;

        /* Revenue from oil and cake */
        L_OIL_REVENUE :=
            (L_OIL_YIELD_KG / P_OIL_SELL_UNIT) * P_OIL_RATE;

        L_CAKE_REVENUE :=
            (L_CAKE_YIELD_KG / P_CAKE_SELL_UNIT) * P_CAKE_RATE;

        L_TOTAL_REVENUE := L_OIL_REVENUE + L_CAKE_REVENUE;

        /* Single output: profit/loss per 1000 kg (1 ton) */
        P_NET_PROFIT_LOSS :=
            ROUND(L_TOTAL_REVENUE - L_TOTAL_COST, 2);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END P_CALCULATE_CRUSHING_PL;


    /* ==================================================
       3: OIL MILL RECOVERY
       ================================================== */
    PROCEDURE P_CALCULATE_OIL_RECOVERY (
        P_INPUT_SEED_KG   IN NUMBER,
        P_OIL_PERCENT     IN NUMBER,
        P_CAKE_PERCENT    IN NUMBER,

        P_OIL_YIELD_KG    OUT NUMBER,
        P_OIL_YIELD_PCT   OUT NUMBER,
        P_CAKE_YIELD_KG   OUT NUMBER,
        P_CAKE_YIELD_PCT  OUT NUMBER,
        P_WASTE_YIELD_KG  OUT NUMBER,
        P_WASTE_YIELD_PCT OUT NUMBER
    ) IS
        L_WASTE_PERCENT NUMBER;
    BEGIN
        P_OIL_YIELD_KG    := NULL;
        P_OIL_YIELD_PCT   := NULL;
        P_CAKE_YIELD_KG   := NULL;
        P_CAKE_YIELD_PCT  := NULL;
        P_WASTE_YIELD_KG  := NULL;
        P_WASTE_YIELD_PCT := NULL;

        /* Required fields */
        IF P_INPUT_SEED_KG IS NULL
           OR P_OIL_PERCENT IS NULL
           OR P_CAKE_PERCENT IS NULL
        THEN
            RAISE_APPLICATION_ERROR(-20021,'Oil Mill Recovery: All input fields are required.');
        END IF;

        /* Validate input weight */
        IF P_INPUT_SEED_KG <= 0 THEN
            RAISE_APPLICATION_ERROR(-20022,'Total seed processed must be greater than zero.');
        END IF;

        /* Validate percentages */
        IF P_OIL_PERCENT < 0 OR P_OIL_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20023,'Oil recovery percentage must be between 0 and 100.');
        END IF;

        IF P_CAKE_PERCENT < 0 OR P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20024,'Cake recovery percentage must be between 0 and 100.');
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RAISE_APPLICATION_ERROR(-20025,'Oil and cake percentages cannot total more than 100.');
        END IF;

        /* Waste percentage */
        L_WASTE_PERCENT :=
            100 - P_OIL_PERCENT - P_CAKE_PERCENT;

        /* Six outputs: quantity and percentage for each category */
        P_OIL_YIELD_KG :=
            ROUND(P_INPUT_SEED_KG * P_OIL_PERCENT / 100, 2);

        P_OIL_YIELD_PCT :=
            ROUND(P_OIL_PERCENT, 2);

        P_CAKE_YIELD_KG :=
            ROUND(P_INPUT_SEED_KG * P_CAKE_PERCENT / 100, 2);

        P_CAKE_YIELD_PCT :=
            ROUND(P_CAKE_PERCENT, 2);

        P_WASTE_YIELD_KG :=
            ROUND(P_INPUT_SEED_KG * L_WASTE_PERCENT / 100, 2);

        P_WASTE_YIELD_PCT :=
            ROUND(L_WASTE_PERCENT, 2);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END P_CALCULATE_OIL_RECOVERY;


    /* ==================================================
       1: KHAL COST (Function)
       ================================================== */
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
    ) RETURN VARCHAR2 IS
        L_SEED_COST       NUMBER;
        L_PROCESS_COST    NUMBER;
        L_TOTAL_COST      NUMBER;
        L_OIL_YIELD_KG    NUMBER;
        L_CAKE_YIELD_KG   NUMBER;
        L_OIL_REVENUE     NUMBER;
        L_CAKE_COST_PER_KG NUMBER;
        L_SELECTED_KG     NUMBER;
    BEGIN
        /* Required fields */
        IF P_SEED_RATE IS NULL OR P_SEED_BUY_UNIT IS NULL OR P_OIL_RATE IS NULL
           OR P_OIL_SELL_UNIT IS NULL OR P_PROCESSING_EXPENSE IS NULL
           OR P_EXPENSE_UNIT IS NULL OR P_OIL_PERCENT IS NULL
           OR P_CAKE_PERCENT IS NULL OR P_SHOW_COST_PER IS NULL
        THEN
            RETURN 'Error: Khal Cost: All input fields are required.';
        END IF;

        /* Amount validation */
        IF P_SEED_RATE < 0 OR P_OIL_RATE < 0 OR P_PROCESSING_EXPENSE < 0 THEN
            RETURN 'Error: Rates and processing expense cannot be negative.';
        END IF;

        /* Unit validation */
        IF P_SEED_BUY_UNIT NOT IN (20, 100, 1000) THEN
            RETURN 'Error: Invalid seed purchase unit.';
        END IF;

        IF P_EXPENSE_UNIT NOT IN (20, 100, 1000) THEN
            RETURN 'Error: Invalid processing expense unit.';
        END IF;

        IF P_OIL_SELL_UNIT NOT IN (1, 10, 15) THEN
            RETURN 'Error: Invalid oil selling unit.';
        END IF;

        /* Percentage validation */
        IF P_OIL_PERCENT <= 0 OR P_OIL_PERCENT > 100 THEN
            RETURN 'Error: Oil recovery must be greater than 0 and at most 100.';
        END IF;

        IF P_CAKE_PERCENT <= 0 OR P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Cake recovery must be greater than 0 and at most 100.';
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Oil and cake percentages cannot total more than 100.';
        END IF;

        /* Selected output unit */
        CASE UPPER(TRIM(P_SHOW_COST_PER))
            WHEN '50'  THEN L_SELECTED_KG := 50;
            WHEN '20'  THEN L_SELECTED_KG := 20;
            WHEN '100' THEN L_SELECTED_KG := 100;
            WHEN '1'   THEN L_SELECTED_KG := 1;
            ELSE
                RETURN 'Error: Invalid Show Cost Per selection.';
        END CASE;

        /* Calculation */
        L_SEED_COST := (C_BATCH_KG / P_SEED_BUY_UNIT) * P_SEED_RATE;
        L_PROCESS_COST := (C_BATCH_KG / P_EXPENSE_UNIT) * P_PROCESSING_EXPENSE;
        L_TOTAL_COST := L_SEED_COST + L_PROCESS_COST;

        L_OIL_YIELD_KG := C_BATCH_KG * P_OIL_PERCENT / 100;
        L_CAKE_YIELD_KG := C_BATCH_KG * P_CAKE_PERCENT / 100;

        IF L_CAKE_YIELD_KG <= 0 THEN
            RETURN 'Error: Cake yield must be greater than zero.';
        END IF;

        L_OIL_REVENUE := (L_OIL_YIELD_KG / P_OIL_SELL_UNIT) * P_OIL_RATE;
        L_CAKE_COST_PER_KG := (L_TOTAL_COST - L_OIL_REVENUE) / L_CAKE_YIELD_KG;

        RETURN TO_CHAR(ROUND(L_CAKE_COST_PER_KG * L_SELECTED_KG, 2));

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END CALCULATE_KHAL_PARITY;


    /* ==================================================
       2: PROFIT / CRUSHING P&L (Function)
       ================================================== */
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
    ) RETURN VARCHAR2 IS
        L_SEED_COST       NUMBER;
        L_PROCESS_COST    NUMBER;
        L_TOTAL_COST      NUMBER;
        L_OIL_YIELD_KG    NUMBER;
        L_CAKE_YIELD_KG   NUMBER;
        L_OIL_REVENUE     NUMBER;
        L_CAKE_REVENUE    NUMBER;
        L_TOTAL_REVENUE   NUMBER;
    BEGIN
        /* Required fields */
        IF P_SEED_RATE IS NULL OR P_SEED_BUY_UNIT IS NULL OR P_OIL_RATE IS NULL
           OR P_OIL_SELL_UNIT IS NULL OR P_CAKE_RATE IS NULL OR P_CAKE_SELL_UNIT IS NULL
           OR P_PROCESSING_EXPENSE IS NULL OR P_EXPENSE_UNIT IS NULL
           OR P_OIL_PERCENT IS NULL OR P_CAKE_PERCENT IS NULL
        THEN
            RETURN 'Error: Crushing P&L: All input fields are required.';
        END IF;

        /* Amount validation */
        IF P_SEED_RATE < 0 OR P_OIL_RATE < 0 OR P_CAKE_RATE < 0 OR P_PROCESSING_EXPENSE < 0 THEN
            RETURN 'Error: Rates and processing expense cannot be negative.';
        END IF;

        /* Unit validation */
        IF P_SEED_BUY_UNIT NOT IN (20, 100, 1000) THEN
            RETURN 'Error: Invalid seed purchase unit.';
        END IF;

        IF P_EXPENSE_UNIT NOT IN (20, 100, 1000) THEN
            RETURN 'Error: Invalid processing expense unit.';
        END IF;

        IF P_OIL_SELL_UNIT NOT IN (1, 10, 15) THEN
            RETURN 'Error: Invalid oil selling unit.';
        END IF;

        IF P_CAKE_SELL_UNIT NOT IN (1, 20, 50, 100) THEN
            RETURN 'Error: Invalid cake selling unit.';
        END IF;

        /* Percentage validation */
        IF P_OIL_PERCENT <= 0 OR P_OIL_PERCENT > 100 THEN
            RETURN 'Error: Oil percentage must be greater than 0 and at most 100.';
        END IF;

        IF P_CAKE_PERCENT <= 0 OR P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Cake percentage must be greater than 0 and at most 100.';
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Oil and cake percentages cannot total more than 100.';
        END IF;

        /* Calculation */
        L_SEED_COST := (C_BATCH_KG / P_SEED_BUY_UNIT) * P_SEED_RATE;
        L_PROCESS_COST := (C_BATCH_KG / P_EXPENSE_UNIT) * P_PROCESSING_EXPENSE;
        L_TOTAL_COST := L_SEED_COST + L_PROCESS_COST;

        L_OIL_YIELD_KG := C_BATCH_KG * P_OIL_PERCENT / 100;
        L_CAKE_YIELD_KG := C_BATCH_KG * P_CAKE_PERCENT / 100;

        L_OIL_REVENUE := (L_OIL_YIELD_KG / P_OIL_SELL_UNIT) * P_OIL_RATE;
        L_CAKE_REVENUE := (L_CAKE_YIELD_KG / P_CAKE_SELL_UNIT) * P_CAKE_RATE;
        L_TOTAL_REVENUE := L_OIL_REVENUE + L_CAKE_REVENUE;

        RETURN TO_CHAR(ROUND(L_TOTAL_REVENUE - L_TOTAL_COST, 2));

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END CALCULATE_CRUSHING_PL;


    /* ==================================================
       3: OIL MILL RECOVERY (Function)
       ================================================== */
    FUNCTION CALCULATE_OIL_RECOVERY (
        P_INPUT_SEED_KG  IN NUMBER,
        P_OIL_PERCENT    IN NUMBER,
        P_CAKE_PERCENT   IN NUMBER,
        P_RETURN_TYPE    IN VARCHAR2
    ) RETURN VARCHAR2 IS
        L_WASTE_PERCENT NUMBER;
        L_REQ_TYPE      VARCHAR2(50);
    BEGIN
        /* Required fields */
        IF P_INPUT_SEED_KG IS NULL OR P_OIL_PERCENT IS NULL OR P_CAKE_PERCENT IS NULL OR P_RETURN_TYPE IS NULL THEN
            RETURN 'Error: Oil Mill Recovery: All input fields are required.';
        END IF;

        /* Validate input weight */
        IF P_INPUT_SEED_KG <= 0 THEN
            RETURN 'Error: Total seed processed must be greater than zero.';
        END IF;

        /* Validate percentages */
        IF P_OIL_PERCENT < 0 OR P_OIL_PERCENT > 100 THEN
            RETURN 'Error: Oil recovery percentage must be between 0 and 100.';
        END IF;

        IF P_CAKE_PERCENT < 0 OR P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Cake recovery percentage must be between 0 and 100.';
        END IF;

        IF P_OIL_PERCENT + P_CAKE_PERCENT > 100 THEN
            RETURN 'Error: Oil and cake percentages cannot total more than 100.';
        END IF;

        /* Waste percentage */
        L_WASTE_PERCENT := 100 - P_OIL_PERCENT - P_CAKE_PERCENT;
        L_REQ_TYPE := UPPER(TRIM(P_RETURN_TYPE));

        /* Return specific output based on P_RETURN_TYPE */
        IF L_REQ_TYPE = 'OIL_KG' THEN
            RETURN TO_CHAR(ROUND(P_INPUT_SEED_KG * P_OIL_PERCENT / 100, 2));
            
        ELSIF L_REQ_TYPE = 'OIL_PCT' THEN
            RETURN TO_CHAR(ROUND(P_OIL_PERCENT, 2));
            
        ELSIF L_REQ_TYPE = 'CAKE_KG' THEN
            RETURN TO_CHAR(ROUND(P_INPUT_SEED_KG * P_CAKE_PERCENT / 100, 2));
            
        ELSIF L_REQ_TYPE = 'CAKE_PCT' THEN
            RETURN TO_CHAR(ROUND(P_CAKE_PERCENT, 2));
            
        ELSIF L_REQ_TYPE = 'WASTE_KG' THEN
            RETURN TO_CHAR(ROUND(P_INPUT_SEED_KG * L_WASTE_PERCENT / 100, 2));
            
        ELSIF L_REQ_TYPE = 'WASTE_PCT' THEN
            RETURN TO_CHAR(ROUND(L_WASTE_PERCENT, 2));
            
        ELSE
            RETURN 'Error: Invalid P_RETURN_TYPE. Use OIL_KG, OIL_PCT, CAKE_KG, CAKE_PCT, WASTE_KG, or WASTE_PCT.';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END CALCULATE_OIL_RECOVERY;


END PKG_OIL_MILL_CALCULATOR;
/