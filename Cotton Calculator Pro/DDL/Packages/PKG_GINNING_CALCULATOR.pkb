create or replace PACKAGE BODY PKG_GINNING_CALCULATOR AS

    ------------------------------------------------------------------
    -- 1. GINNING PARITY
    -- Calculates production cost per 355.62 kg lint candy
    ------------------------------------------------------------------
    PROCEDURE P_CALCULATE_PARITY (
        P_KAPAS_RATE         IN  NUMBER,
        P_KAPAS_UNIT         IN  NUMBER,
        P_SEED_RATE          IN  NUMBER,
        P_SEED_UNIT          IN  NUMBER,
        P_EXPENSE_PER_MAUND  IN  NUMBER,
        P_EXPECTED_GOT       IN  NUMBER,
        P_EXPECTED_SHORTAGE  IN  NUMBER,
        P_PARITY_COST        OUT VARCHAR2
    )
    IS
        L_SEED_PERCENT       NUMBER;
        L_REQUIRED_KAPAS_KG  NUMBER;
        L_GENERATED_SEED_KG  NUMBER;
        L_COST_OF_KAPAS      NUMBER;
        L_PROCESSING_COST    NUMBER;
        L_RECOVERY_FROM_SEED NUMBER;
        L_NET_CANDY_COST     NUMBER;
    BEGIN
        P_PARITY_COST := NULL;

        -- Validate mandatory inputs
        IF P_KAPAS_RATE IS NULL
           OR P_KAPAS_UNIT IS NULL
           OR P_SEED_RATE IS NULL
           OR P_SEED_UNIT IS NULL
           OR P_EXPENSE_PER_MAUND IS NULL
           OR P_EXPECTED_GOT IS NULL
           OR P_EXPECTED_SHORTAGE IS NULL
        THEN
            -- RAISE_APPLICATION_ERROR(-20001,'Parity: Please enter all required inputs.');

            RETURN;
        END IF;

        -- Validate units
        IF P_KAPAS_UNIT NOT IN (20, 100) THEN
            -- RAISE_APPLICATION_ERROR(-20002,'Parity: Kapas unit must be 20 or 100.');

            RETURN;
        END IF;

        IF P_SEED_UNIT NOT IN (20, 100) THEN
            -- RAISE_APPLICATION_ERROR(-20003,'Parity: Seed unit must be 20 or 100.');

            RETURN;
        END IF;

        -- Validate rates and expense
        IF P_KAPAS_RATE < 0
           OR P_SEED_RATE < 0
           OR P_EXPENSE_PER_MAUND < 0
        THEN
            -- RAISE_APPLICATION_ERROR(-20004,'Parity: Rates and expenses cannot be negative.');

            RETURN;
        END IF;

        -- Validate GOT and shortage
        IF P_EXPECTED_GOT <= 0 OR P_EXPECTED_GOT > 100 THEN
            -- RAISE_APPLICATION_ERROR(-20005,'Parity: GOT must be greater than 0 and at most 100.');

            RETURN;
        END IF;

        IF P_EXPECTED_SHORTAGE < 0
           OR P_EXPECTED_SHORTAGE >= 100
        THEN
            -- RAISE_APPLICATION_ERROR(-20006,'Parity: Shortage must be between 0 and less than 100.');

            RETURN;
        END IF;

        IF P_EXPECTED_GOT + P_EXPECTED_SHORTAGE >= 100 THEN
            -- RAISE_APPLICATION_ERROR(-20007,'Parity: GOT plus shortage must be less than 100%.');

            RETURN;
        END IF;

        -- Calculation
        L_SEED_PERCENT :=
            100 - P_EXPECTED_GOT - P_EXPECTED_SHORTAGE;

        L_REQUIRED_KAPAS_KG :=
            355.62 / (P_EXPECTED_GOT / 100);

        L_GENERATED_SEED_KG :=
            L_REQUIRED_KAPAS_KG * (L_SEED_PERCENT / 100);

        L_COST_OF_KAPAS :=
            (L_REQUIRED_KAPAS_KG / P_KAPAS_UNIT)
            * P_KAPAS_RATE;

        L_PROCESSING_COST :=
            (L_REQUIRED_KAPAS_KG / 20)
            * P_EXPENSE_PER_MAUND;

        L_RECOVERY_FROM_SEED :=
            (L_GENERATED_SEED_KG / P_SEED_UNIT)
            * P_SEED_RATE;

        L_NET_CANDY_COST :=
              L_COST_OF_KAPAS
            + L_PROCESSING_COST
            - L_RECOVERY_FROM_SEED;

        P_PARITY_COST := ROUND(L_NET_CANDY_COST);

    END P_CALCULATE_PARITY;


    ------------------------------------------------------------------
    -- 2. REVERSE PARITY
    -- Calculates break-even Kapas rate per 20 kg Maund
    ------------------------------------------------------------------
    PROCEDURE P_CALCULATE_REVERSE_PARITY (
        P_LINT_PRICE         IN  NUMBER,
        P_SEED_PRICE         IN  NUMBER,
        P_SEED_UNIT          IN  NUMBER,
        P_EXPENSE            IN  NUMBER,
        P_GOT                IN  NUMBER,
        P_SHORTAGE           IN  NUMBER,
        P_LINT_YIELD_KG      OUT VARCHAR2,
        P_SEED_YIELD_KG      OUT VARCHAR2,
        P_LINT_VALUE         OUT VARCHAR2,
        P_SEED_VALUE         OUT VARCHAR2,
        P_TOTAL_REALIZATION  OUT VARCHAR2,
        P_MAX_KAPAS_RATE     OUT VARCHAR2,
        P_REV_KAPAS_RATE     OUT VARCHAR2
    )
    IS
    BEGIN
        -- Initialize outputs
        P_LINT_YIELD_KG     := NULL;
        P_SEED_YIELD_KG     := NULL;
        P_LINT_VALUE        := NULL;
        P_SEED_VALUE        := NULL;
        P_TOTAL_REALIZATION := NULL;
        P_MAX_KAPAS_RATE    := NULL;
        P_REV_KAPAS_RATE    := NULL;

        -- Mandatory inputs
        IF P_LINT_PRICE IS NULL
           OR P_SEED_PRICE IS NULL
           OR P_SEED_UNIT IS NULL
           OR P_EXPENSE IS NULL
           OR P_GOT IS NULL
           OR P_SHORTAGE IS NULL
        THEN
            -- RAISE_APPLICATION_ERROR(-20011,'Reverse Parity: Please enter all required inputs.');

            RETURN;
        END IF;

        -- Unit validation
        IF P_SEED_UNIT NOT IN (20, 100) THEN
            -- RAISE_APPLICATION_ERROR(-20012,'Reverse Parity: Seed unit must be 20 or 100.');

            RETURN;
        END IF;

        -- Rate validation
        IF P_LINT_PRICE < 0
           OR P_SEED_PRICE < 0
           OR P_EXPENSE < 0
        THEN
            -- RAISE_APPLICATION_ERROR(-20013,'Reverse Parity: Prices and expense cannot be negative.');

            RETURN;
        END IF;

        -- Percentage validation
        IF P_GOT <= 0 OR P_GOT > 100 THEN
            -- RAISE_APPLICATION_ERROR(-20014,'Reverse Parity: GOT must be greater than 0 and at most 100.');

            RETURN;
        END IF;

        IF P_SHORTAGE < 0 OR P_SHORTAGE >= 100 THEN
            -- RAISE_APPLICATION_ERROR(-20015,'Reverse Parity: Shortage must be between 0 and less than 100.');

            RETURN;
        END IF;

        IF P_GOT + P_SHORTAGE >= 100 THEN
            -- RAISE_APPLICATION_ERROR(-20016,'Reverse Parity: GOT plus shortage must be less than 100%.');
            
            RETURN;
        END IF;

        -- Yield from 20 kg raw Kapas
        P_LINT_YIELD_KG :=
            20 * (P_GOT / 100);

        P_SEED_YIELD_KG :=
            20 * ((100 - P_GOT - P_SHORTAGE) / 100);

        -- Realization values
        P_LINT_VALUE :=
            (P_LINT_YIELD_KG / 355.62) * P_LINT_PRICE;

        P_SEED_VALUE :=
            (P_SEED_YIELD_KG / P_SEED_UNIT) * P_SEED_PRICE;

        P_TOTAL_REALIZATION :=
            P_LINT_VALUE + P_SEED_VALUE;

        P_MAX_KAPAS_RATE :=
            P_TOTAL_REALIZATION - P_EXPENSE;

        P_REV_KAPAS_RATE :=
            ROUND(P_MAX_KAPAS_RATE);

    END P_CALCULATE_REVERSE_PARITY;


    ------------------------------------------------------------------
    -- 3. OUTPUT RATIO
    -- Calculates lint, seed and waste percentages
    ------------------------------------------------------------------
    
    PROCEDURE P_CALCULATE_OUTPUT_RATIO (
        P_INPUT_WEIGHT   IN NUMBER,
        P_LINT_WEIGHT    IN NUMBER,
        P_SEED_WEIGHT    IN NUMBER,
        P_WASTE_WEIGHT   IN NUMBER,
        P_WEIGHT_UNIT    IN VARCHAR2,
        P_LINT_PERCENT OUT NUMBER,
        P_SEED_PERCENT   OUT NUMBER,
        P_WASTE_PERCENT  OUT NUMBER,
        P_TOTAL_PERCENT  OUT NUMBER,
        P_IS_BALANCED    OUT VARCHAR2
    )
    IS
        L_WEIGHT_UNIT VARCHAR2(10);
    BEGIN
        -- Initialize output parameters
        P_LINT_PERCENT     := NULL;
        P_SEED_PERCENT  := NULL;
        P_WASTE_PERCENT := NULL;
        P_TOTAL_PERCENT := NULL;
        P_IS_BALANCED   := NULL;

        -- Validate required inputs
        IF P_INPUT_WEIGHT IS NULL
           OR P_LINT_WEIGHT IS NULL
           OR P_SEED_WEIGHT IS NULL
           OR P_WASTE_WEIGHT IS NULL
           OR P_WEIGHT_UNIT IS NULL
        THEN
            -- RAISE_APPLICATION_ERROR(-20021,'Output Ratio: Enter all weights and select G or KG.');

            RETURN;
        END IF;

        -- Validate selected unit
        L_WEIGHT_UNIT := UPPER(TRIM(P_WEIGHT_UNIT));

        IF L_WEIGHT_UNIT NOT IN ('G', 'KG') THEN
            -- RAISE_APPLICATION_ERROR(-20022,'Output Ratio: Weight unit must be G or KG.');

            RETURN;
        END IF;

        -- Validate weights
        IF P_INPUT_WEIGHT <= 0
           OR P_LINT_WEIGHT < 0
           OR P_SEED_WEIGHT < 0
           OR P_WASTE_WEIGHT < 0
        THEN
            -- RAISE_APPLICATION_ERROR(-20023,'Output Ratio: Input weight must be positive and output weights cannot be negative.');

            RETURN;
        END IF;

        -- Calculate percentages.
        -- G and KG cancel out because all weights use the same unit.
        P_LINT_PERCENT   :=
            (P_LINT_WEIGHT / P_INPUT_WEIGHT) * 100;

        P_SEED_PERCENT :=
            (P_SEED_WEIGHT / P_INPUT_WEIGHT) * 100;

        P_WASTE_PERCENT :=
            (P_WASTE_WEIGHT / P_INPUT_WEIGHT) * 100;

        P_TOTAL_PERCENT :=
              P_LINT_PERCENT  
            + P_SEED_PERCENT
            + P_WASTE_PERCENT;

        -- Balance status
        IF ROUND(P_TOTAL_PERCENT) = 100 THEN
            P_IS_BALANCED := 'Y';
        ELSE
            P_IS_BALANCED := 'N';
        END IF;

    END P_CALCULATE_OUTPUT_RATIO;




    ------------------------------------------------------------------
    -- 1. GINNING PARITY
    -- Calculates production cost per 355.62 kg lint candy
    ------------------------------------------------------------------
    FUNCTION F_CALCULATE_PARITY (
        P_KAPAS_RATE         IN  NUMBER,
        P_KAPAS_UNIT         IN  NUMBER,
        P_SEED_RATE          IN  NUMBER,
        P_SEED_UNIT          IN  NUMBER,
        P_EXPENSE_PER_MAUND  IN  NUMBER,
        P_EXPECTED_GOT       IN  NUMBER,
        P_EXPECTED_SHORTAGE  IN  NUMBER
    ) RETURN VARCHAR2
    IS
        L_SEED_PERCENT       NUMBER;
        L_REQUIRED_KAPAS_KG  NUMBER;
        L_GENERATED_SEED_KG  NUMBER;
        L_COST_OF_KAPAS      NUMBER;
        L_PROCESSING_COST    NUMBER;
        L_RECOVERY_FROM_SEED NUMBER;
        L_NET_CANDY_COST     NUMBER;
    BEGIN
        -- Validate mandatory inputs
        IF P_KAPAS_RATE IS NULL OR P_KAPAS_UNIT IS NULL OR P_SEED_RATE IS NULL
           OR P_SEED_UNIT IS NULL OR P_EXPENSE_PER_MAUND IS NULL
           OR P_EXPECTED_GOT IS NULL OR P_EXPECTED_SHORTAGE IS NULL
        THEN
            RETURN 'Error: Parity - Please enter all required inputs.';
        END IF;

        -- Validate units
        IF P_KAPAS_UNIT NOT IN (20, 100) THEN
            RETURN 'Error: Parity - Kapas unit must be 20 or 100.';
        END IF;

        IF P_SEED_UNIT NOT IN (20, 100) THEN
            RETURN 'Error: Parity - Seed unit must be 20 or 100.';
        END IF;

        -- Validate rates and expense
        IF P_KAPAS_RATE < 0 OR P_SEED_RATE < 0 OR P_EXPENSE_PER_MAUND < 0 THEN
            RETURN 'Error: Parity - Rates and expenses cannot be negative.';
        END IF;

        -- Validate GOT and shortage
        IF P_EXPECTED_GOT <= 0 OR P_EXPECTED_GOT > 100 THEN
            RETURN 'Error: Parity - GOT must be greater than 0 and at most 100.';
        END IF;

        IF P_EXPECTED_SHORTAGE < 0 OR P_EXPECTED_SHORTAGE >= 100 THEN
            RETURN 'Error: Parity - Shortage must be between 0 and less than 100.';
        END IF;

        IF P_EXPECTED_GOT + P_EXPECTED_SHORTAGE >= 100 THEN
            RETURN 'Error: Parity - GOT plus shortage must be less than 100%.';
        END IF;

        -- Calculation
        L_SEED_PERCENT := 100 - P_EXPECTED_GOT - P_EXPECTED_SHORTAGE;
        L_REQUIRED_KAPAS_KG := 355.62 / (P_EXPECTED_GOT / 100);
        L_GENERATED_SEED_KG := L_REQUIRED_KAPAS_KG * (L_SEED_PERCENT / 100);
        
        L_COST_OF_KAPAS := (L_REQUIRED_KAPAS_KG / P_KAPAS_UNIT) * P_KAPAS_RATE;
        L_PROCESSING_COST := (L_REQUIRED_KAPAS_KG / 20) * P_EXPENSE_PER_MAUND;
        L_RECOVERY_FROM_SEED := (L_GENERATED_SEED_KG / P_SEED_UNIT) * P_SEED_RATE;
        
        L_NET_CANDY_COST := L_COST_OF_KAPAS + L_PROCESSING_COST - L_RECOVERY_FROM_SEED;

        RETURN TO_CHAR(ROUND(L_NET_CANDY_COST, 3));

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END F_CALCULATE_PARITY;


    ------------------------------------------------------------------
    -- 2. REVERSE PARITY
    -- Calculates break-even Kapas rate per 20 kg Maund (Returns MAX_KAPAS_RATE)
    ------------------------------------------------------------------
    FUNCTION F_CALCULATE_REVERSE_PARITY (
        P_LINT_PRICE         IN  NUMBER,
        P_SEED_PRICE         IN  NUMBER,
        P_SEED_UNIT          IN  NUMBER,
        P_EXPENSE            IN  NUMBER,
        P_GOT                IN  NUMBER,
        P_SHORTAGE           IN  NUMBER
    ) RETURN VARCHAR2
    IS
        L_LINT_YIELD_KG      NUMBER;
        L_SEED_YIELD_KG      NUMBER;
        L_LINT_VALUE         NUMBER;
        L_SEED_VALUE         NUMBER;
        L_TOTAL_REALIZATION  NUMBER;
        L_MAX_KAPAS_RATE     NUMBER;
    BEGIN
        -- Mandatory inputs
        IF P_LINT_PRICE IS NULL OR P_SEED_PRICE IS NULL OR P_SEED_UNIT IS NULL
           OR P_EXPENSE IS NULL OR P_GOT IS NULL OR P_SHORTAGE IS NULL
        THEN
            RETURN 'Error: Reverse Parity - Please enter all required inputs.';
        END IF;

        -- Unit validation
        IF P_SEED_UNIT NOT IN (20, 100) THEN
            RETURN 'Error: Reverse Parity - Seed unit must be 20 or 100.';
        END IF;

        -- Rate validation
        IF P_LINT_PRICE < 0 OR P_SEED_PRICE < 0 OR P_EXPENSE < 0 THEN
            RETURN 'Error: Reverse Parity - Prices and expense cannot be negative.';
        END IF;

        -- Percentage validation
        IF P_GOT <= 0 OR P_GOT > 100 THEN
            RETURN 'Error: Reverse Parity - GOT must be greater than 0 and at most 100.';
        END IF;

        IF P_SHORTAGE < 0 OR P_SHORTAGE >= 100 THEN
            RETURN 'Error: Reverse Parity - Shortage must be between 0 and less than 100.';
        END IF;

        IF P_GOT + P_SHORTAGE >= 100 THEN
            RETURN 'Error: Reverse Parity - GOT plus shortage must be less than 100%.';
        END IF;

        -- Yield from 20 kg raw Kapas
        L_LINT_YIELD_KG := 20 * (P_GOT / 100);
        L_SEED_YIELD_KG := 20 * ((100 - P_GOT - P_SHORTAGE) / 100);

        -- Realization values
        L_LINT_VALUE := (L_LINT_YIELD_KG / 355.62) * P_LINT_PRICE;
        L_SEED_VALUE := (L_SEED_YIELD_KG / P_SEED_UNIT) * P_SEED_PRICE;
        L_TOTAL_REALIZATION := L_LINT_VALUE + L_SEED_VALUE;

        -- Calculate P_MAX_KAPAS_RATE
        L_MAX_KAPAS_RATE := L_TOTAL_REALIZATION - P_EXPENSE;

        -- Returning ONLY Max Kapas Rate (rounded to 3 decimals as per original logic if needed)
        RETURN TO_CHAR(ROUND(L_MAX_KAPAS_RATE, 3));

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END F_CALCULATE_REVERSE_PARITY;


    ------------------------------------------------------------------
    -- 3. OUTPUT RATIO
    -- Calculates percentage based on requested P_PERCENTAGE_TYPE
    ------------------------------------------------------------------
    FUNCTION F_CALCULATE_OUTPUT_RATIO (
        P_INPUT_WEIGHT       IN NUMBER,
        P_LINT_WEIGHT        IN NUMBER,
        P_SEED_WEIGHT        IN NUMBER,
        P_WASTE_WEIGHT       IN NUMBER,
        P_WEIGHT_UNIT        IN VARCHAR2,
        P_PERCENTAGE_TYPE    IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        L_WEIGHT_UNIT VARCHAR2(10);
        L_REQ_TYPE    VARCHAR2(20);
    BEGIN
        -- Validate required inputs
        IF P_INPUT_WEIGHT IS NULL OR P_LINT_WEIGHT IS NULL 
           OR P_SEED_WEIGHT IS NULL OR P_WASTE_WEIGHT IS NULL 
           OR P_WEIGHT_UNIT IS NULL OR P_PERCENTAGE_TYPE IS NULL
        THEN
            RETURN 'Error: Output Ratio - Enter all weights, unit and percentage type.';
        END IF;

        -- Validate selected unit
        L_WEIGHT_UNIT := UPPER(TRIM(P_WEIGHT_UNIT));
        IF L_WEIGHT_UNIT NOT IN ('G', 'KG') THEN
            RETURN 'Error: Output Ratio - Weight unit must be G or KG.';
        END IF;

        -- Validate weights
        IF P_INPUT_WEIGHT <= 0 OR P_LINT_WEIGHT < 0 OR P_SEED_WEIGHT < 0 OR P_WASTE_WEIGHT < 0 THEN
            RETURN 'Error: Output Ratio - Input weight must be positive and outputs cannot be negative.';
        END IF;

        -- Return requested percentage based on P_PERCENTAGE_TYPE
        L_REQ_TYPE := UPPER(TRIM(P_PERCENTAGE_TYPE));

        IF L_REQ_TYPE = 'LINT' THEN
            RETURN TO_CHAR((P_LINT_WEIGHT / P_INPUT_WEIGHT) * 100);
            
        ELSIF L_REQ_TYPE = 'SEED' THEN
            RETURN TO_CHAR((P_SEED_WEIGHT / P_INPUT_WEIGHT) * 100);
            
        ELSIF L_REQ_TYPE = 'WASTE' THEN
            RETURN TO_CHAR((P_WASTE_WEIGHT / P_INPUT_WEIGHT) * 100);
            
        ELSIF L_REQ_TYPE = 'TOTAL' THEN
            RETURN TO_CHAR(((P_LINT_WEIGHT + P_SEED_WEIGHT + P_WASTE_WEIGHT) / P_INPUT_WEIGHT) * 100);
            
        ELSE
            RETURN 'Error: Invalid Percentage Type. Use LINT, SEED, WASTE, or TOTAL.';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END F_CALCULATE_OUTPUT_RATIO;


END PKG_GINNING_CALCULATOR;
/