
% returns tabular data related to % DV

function [no_vals, no_pcts, just_numbers, gmg, DV] = get_daily_values()

    % "no_vals" contains all tokens that are NOT followed by values.
    no_vals = { 'AmountPerServing'; '%DailyValue*' };

    % "no_pcts" contains all tokens in gmg that are NOT in DV
    no_pcts = { 'Sugars'; 'Protein'; 'TransFat';
                'PolyunsaturatedFat'; 'MonounsaturatedFat';
                'SolubleFiber'; 'InsolubleFiber';
              };
          
    % "just_numbers" contains all tokens followed by, well, just numbers.
    just_numbers = { 'Calories'; 'CaloriesfromFat' };
          
    gmg.TotalFat = 'g';
    gmg.SaturatedFat = 'g';
    gmg.PolyunsaturatedFat = 'g';
    gmg.MonounsaturatedFat = 'g';
    gmg.TransFat = 'g';
    gmg.Cholesterol = 'mg';
    gmg.Sodium = 'mg';
    gmg.Potassium = 'mg';
    gmg.TotalCarbohydrate = 'g';
    gmg.DietaryFiber = 'g';
    gmg.SolubleFiber = 'g';
    gmg.InsolubleFiber = 'g';
    gmg.Sugars = 'g';
    gmg.Protein = 'g';
          
    % Taken from
    % http://www.fda.gov/food/ingredientspackaginglabeling/labelingnutrition/ucm274593.htm#see5
    % and more (incl. vitamins) from
    % http://www.fda.gov/Food/GuidanceRegulation/GuidanceDocumentsRegulatoryInformation/LabelingNutrition/ucm064928.htm
    DV.TotalFat = 65; % g
    DV.SaturatedFat = 20; % g
    DV.Cholesterol = 300; % mg
    DV.Sodium = 2400; % mg
    DV.Potassium = 3500; % mg
    DV.TotalCarbohydrate = 300; % g
    DV.DietaryFiber = 25; % g
    
%     Protein	50 g
%     Vitamin A	5000 International Units (IU)
%     Vitamin C	60 mg
%     Calcium	1000 mg
%     Iron	18 mg