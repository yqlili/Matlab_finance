%% Matlab for Finance - Individual Assignment
% Please use your last name as your m-file name. In my case the file name 
% would be Schoch.m
%%
% *Yeqing Li 

%% 
clc
clear
load('Data.mat')

%% 1 Sample breakdown

% count each variables
publicUS = sum(DealData.PublicTarget == 1 & DealData.UStarget == 1);
publicForeign = sum(DealData.PublicTarget == 1 & DealData.UStarget == 0);
privateUS = sum(DealData.PublicTarget == 0 & DealData.UStarget == 1);
privateForeign = sum(DealData.PublicTarget == 0 & DealData.UStarget == 0);

% create table
summaryTable = array2table([publicUS, publicForeign; privateUS, privateForeign], ...
    'RowNames', {'Public Targets', 'Private Targets'}, ...
    'VariableNames', {'U.S. Targets', 'Foreign Targets'})
%% 2 a Event study

% remove foreign targets
DealData = DealData(DealData.UStarget == 1, :);
% initialization of the CAR vector
CAR_vector = zeros(height(DealData), 1);
% loop over all rows in the DealData

% for ...
for i = 1:height(DealData)
    % in the loop, extract the current deal row and save the PERMNO, 
    % PERMCO, and DateAnnounced in a new variable
    currentDeal = DealData(i, :);
    PERMNO = currentDeal.PERMNO; 
    PERMCO = currentDeal.PERMCO; 
    DateAnnounced = currentDeal.DateAnnounced;
   
    % extract the StockData for the acquirer of the current deal;
    % identifiers in both data sets are PERMNO and PERMCO, i.e., make 
    % sure that you extract those observations, for which PERMNO and 
    % PERMCO match those in the current deal.
    acquirerStockData = StockData(StockData.PERMNO == PERMNO & StockData.PERMCO == PERMCO, :);
    % find position of DateAnnounced in acquirer stock data
    position = find(acquirerStockData.date == DateAnnounced);
    % keep only those observations which are 205 rows before and up to 1
    % row after the position of the announcement date (overall 207 days, 
    % i.e., your array should have 207 rows)
    eventWindowData = acquirerStockData(position - 205 : position + 1, :);
    % create an event dummy, which is zero for the first 204 and 1/3 in the
    % last three rows
    eventDummy = zeros(207, 1);
    eventDummy(end-2:end) = 1/3;
    % calculate the event dummy coefficient (b2) using the calcBeta
    % function given in the material
    result = calcBeta(eventWindowData.rStock_rf, eventDummy);
    CAR_vector(i) = result.beta(2);
end

%% 2 b Histogram

histogram(CAR_vector, 'BinMethod', 'auto', 'Normalization', 'probability')
title('Distribution of Acquirer CARs');
xlabel('CAR');
ylabel('Probability');

% Perform a one-sample t-test
[h, p, ci, stats] = ttest(CAR_vector)

% Comment:
% The tstat is 3.3101 which is much larger than the critical value 1.96.
% Therefore, the null hylothesis should be rejected. The average CAR is
% statistically different from zero.

%% 3 Descriptive statistics

% Append the CAR_vector column to DealData
CAR_vectorTable = array2table(CAR_vector, 'VariableNames', {'CAR_vector'});
DealData = [DealData, CAR_vectorTable];

selectedColumns = {'CAR_vector', 'logDealValue', 'RelativeSize', 'TenderOfferFlag','AllCash', 'Compete', 'Horizontal'};

publicTargets = DealData(DealData.PublicTarget == 1, selectedColumns);
privateTargets = DealData(DealData.PublicTarget == 0, selectedColumns);

Descriptives1 = array2table([table2array(mean(publicTargets))', table2array(std(publicTargets))', table2array(median(publicTargets))'], ...
    'RowNames', {'CAR', 'logDealValue', 'RelativeSize', 'TenderOfferFlag','AllCash', 'Compete', 'Horizontal'}, ...
    'VariableNames', {'Mean', 'SD', 'Median'});
Descriptives1 = table(Descriptives1,'VariableNames',{'Public Targets'});

Descriptives2 = array2table([table2array(mean(privateTargets))', table2array(std(privateTargets))', table2array(median(privateTargets))'], ...
    'VariableNames', {'Mean', 'SD', 'Median'});
Descriptives2 = table(Descriptives2,'VariableNames',{'Private Targets'});

Descriptives = [Descriptives1, Descriptives2]

%% 4 Univariate analyses 

%% 4 a PostDummy
DealData.PostDummy = double(DealData.DateAnnounced >= datetime('2012-04-05'));
%% 4 b Means and standard errors

means = zeros(1, 4);
stdErrors = zeros(1, 4);

% Loop through each category
for i = 1:4
    switch i
        case 1
            % Private Pre
            subset = DealData.CAR_vector(DealData.UStarget == 1 & DealData.PublicTarget == 0 & DealData.PostDummy == 0);
        case 2
            % Private Post
            subset = DealData.CAR_vector(DealData.UStarget == 1 & DealData.PublicTarget == 0 & DealData.PostDummy == 1);
        case 3
            % Public Pre
            subset = DealData.CAR_vector(DealData.UStarget == 1 & DealData.PublicTarget == 1 & DealData.PostDummy == 0);
        case 4
            % Public Post
            subset = DealData.CAR_vector(DealData.UStarget == 1 & DealData.PublicTarget == 1 & DealData.PostDummy == 1);
    end

    % Calculate mean and standard error
    means(i) = mean(subset);
    stdErrors(i) = std(subset) / sqrt(length(subset));
end

disp(['means: ' num2str(means)]);
disp(['stdErrors: ' num2str(stdErrors)]);

%% 4 c t-statistics and significance

% Number of observations in each category
n = arrayfun(@(i) sum(~isnan(DealData.CAR_vector(DealData.UStarget == 1 & ...
    DealData.PublicTarget == (i > 1) & DealData.PostDummy == (mod(i, 2) == 0)))), 1:4);

% Calculate t-statistics
t_stats = means ./ (stdErrors ./ sqrt(n));
disp(['t-statistics: ' num2str(t_stats)]);

% Comment: 
% The means in each category are different from zero since all absolute 
% t-statistics exceed 1.96
%% 5 Baseline results

%% 5 a Interaction

DealData.PrivateDummy = double(DealData.PublicTarget == 0);
DealData.PrivateXPost = DealData.PrivateDummy .* DealData.PostDummy;
%% 5 b Year fixed effects

DealData.Year = year(DealData.DateAnnounced);
uniqueYears = unique(DealData.Year);
% Create a matrix of dummy variables for each unique year
yearDummyMatrix = array2table(double(bsxfun(@eq, DealData.Year, uniqueYears')), ...
    'VariableNames', strcat('YearDummy_', string(uniqueYears)));
DealData = [DealData, yearDummyMatrix];
DealData.Year = [];
%% 5 c OLS regression

PrivateXPostTable = array2table(DealData.PrivateXPost, 'VariableNames', {'PrivateXPost'});
PrivateDummyTable = array2table(DealData.PrivateDummy, 'VariableNames', {'PrivateDummy'});

% i. With year fixed effects, but without control variables:
X1 = [PrivateXPostTable,PrivateDummyTable,yearDummyMatrix];
X1Table = [X1, array2table(DealData.CAR_vector, 'VariableNames', {'CAR_vector'})];
% Run OLS regression
mdl1 = fitlm(X1Table, ['CAR_vector ~ PrivateXPost + PrivateDummy + YearDummy_2010 ' ...
    '+ YearDummy_2011 + YearDummy_2012 + YearDummy_2013'])

% Comment:
% The coefficient of PrivateXPostTable is -0.0025574 which means, CAR is 
% expected to be lower by 0.0025574 units for deals announced on or after 
% April 5, 2012, compared to deals announced before that date, 
% holding other variables constant. However, since the absolute value of 
% tStat is 0.35 which is smaller than 1.96, the null hypothesis cannot be 
% rejected and the variable is not significant in this model, meaning there
% is no evidence that the effect of PrivateXPost is different from zero.
% 
% The coefficient of PrivateDummy is 0.010965, which implies that the CAR 
% is expected to be higher by 0.010965 units for deals with public targets
% compared to deals with private target, holding other variables constant. 
% However, since the absolute value of tStat is 1.8148, which is less 
% than 1.96, the null hypothesis cannot be rejected. The variable PrivateDummy 
% is not statistically significant in this model, suggesting that there is
% no strong evidence that the effect of PrivateDummy is different from zero.

% ii. With year fixed effects and control variables

% Specify control variables
controlVariables = DealData(:, {'logDealValue', 'RelativeSize', 'TenderOfferFlag', 'AllCash', 'Compete', 'Horizontal'});

X2 = [PrivateXPostTable, PrivateDummyTable, yearDummyMatrix, controlVariables];
X2Table = [X2, array2table(DealData.CAR_vector, 'VariableNames', {'CAR_vector'})];

% Run OLS regression
mdl2 = fitlm(X2Table, ['CAR_vector ~ PrivateXPost + PrivateDummy + ' ...
    'YearDummy_2010 + YearDummy_2011 + YearDummy_2012 + YearDummy_2013 + ' ...
    'logDealValue + RelativeSize+ TenderOfferFlag+ AllCash+ Compete + Horizontal'])

% Comment: 
% The coefficient of PrivateXPost is -0.0041642, indicating that the CAR is
% expected to be lower by 0.0041642 units for deals announced on or after 
% April 5, 2012, compared to deals announced before that date, holding other 
% variables constant. However, since the absolute value of tStat is 0.57329, 
% which is smaller than 1.96, the null hypothesis cannot be rejected, and
% the variable is not statistically significant in this model. This suggests
% that there is no strong evidence that the effect of PrivateXPost is 
% different from zero.
%
% The coefficient of PrivateDummy is 0.021855, implying that the CAR is 
% expected to be higher by 0.021855 units for deals with public targets
% compared to deals with private targets, holding other variables constant. 
% Since the absolute value of tStat is 3.209, which is greater 
% than 1.96, the null hypothesis is rejected. The variable PrivateDummy 
% is statistically significant in this model, suggesting that there is
% evidence that the effect of PrivateDummy is different from zero at a 
% conventional significance level of 0.05.

% Potential differences might caused by differnt sample size and including
% different variables.
