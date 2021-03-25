
function list = nutrition_dictionary(extended)

  list = { ...
            'Amount Per Serving';
            'Servings Per Container';
            'Calories';
            'Calories from Fat';
            '% Daily Value*';
            
            'Total Fat';
            'Saturated Fat';
            'Cholesterol';
            'Sodium';
            'Potassium';
            'Total Carbohydrate';
            'Total Carb';
            'Dietary Fiber';
            'Fiber';
            'Sugars';
            'Protein';
            
            % STOP tokens:
            '* Percent Daily Values';
            'Prepared As Directed';
        };
    
    if nargin > 0 && extended
        extended_list = { ...
            'Polyunsaturated Fat';
            'Monounsaturated Fat';
            'Trans Fat';
            'Soluble Fiber';
            'Insoluble Fiber';
            'Vitamin A';
            'Vitamin B6';
            'Vitamin B12';
            'Vitamin C';
            'Vitamin D';
            'Vitamin E';
            'Thiamin';
            'Calcium';
            'Iron';
            'Niacin';
            'Riboflavin';
            'Phosphorus';
            'Pantothenic Acid';
            'Folic Acid';
            'Zinc';
            'Copper';  
        };
        list = [list; extended_list];
    end
            