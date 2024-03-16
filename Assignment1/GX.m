%% Matlab for Finance - Large Group Assignment
% Please replace the X in the file name GX with your group number. Remember
% to include this m-file in your zipped assignment submission.
%%
% Assignment group:
%
% * Name 
% * Name 
% * Name 

%% 1. Load the data and briefly describe the dataset
load('Data.mat')
%% 2. Calculate log-returns
log_return = diff(log(Data{:, 2:7}));
%% 3. Descriptive statistics

meanVec = mean(log_return)*252;
medianVec = median(log_return);
stdVec = std(log_return);
annualizedStdVec = stdVec * sqrt(252);
minVec = min(log_return);
maxVec = max(log_return);

Descriptives = table(meanVec', medianVec', stdVec', minVec', maxVec', 'VariableNames', {'mean', 'median', 'std', 'min', 'max'});

%% 4. Scatter plot
scatter(annualizedStdVec, meanVec, 'filled');
xlabel('Volatility');
ylabel('Annual Return');
title('Return-Volatility Scatter Plot');

%% 5. Sharpe ratio
sharperatio = (meanVec-Descriptives{end, 1})./stdVec;
Descriptives.sharperatio = sharperatio'
%% 6. Risk and return characteristics
% A sharpe ratio larger than 3 is considered to be excellent, between 2
% to 3 is good, between 1 to 2 is accepted. 

% According to the result, Bitcoin has a sharp ratio of more than 10, 
% which means it generates return 10 times higher than the risk-free rate 
% per unit(standard deviation). Therefore it indicates a better 
% risk-adjusted performance. However, Bitcoin also has a higher standard 
% deviation score, which means it is more risky.

% Godl and ETF also has a high score of 7, which also has a good
% performance. And considering the standard deviation, Gold has the lowest
% score which means it is less risky. 

%BankofAmerica also has a good score but has a relatively low return
%compared to ETF, Gold and Bitcoin.

%Therefore, if the investor is risk-preferred and persued high return, they
%should choose Bitcoin. But if the investor is risk-avoid and still want a
%good return, they can choose ETF or Gold, but Gold will be a safer choice.
%% 7. Investment period
%% 7a. Splitted time periods and descriptives
totalRows = size(Data, 1);
splitIndex = round(totalRows / 2);
firstHalf = Data(1:splitIndex, :);
secondHalf = Data(splitIndex+1:end, :);

%firstHalf
logReturns1 = diff(log(firstHalf{:,2:end}));
meanVec1 = mean(logReturns1) * 252;
medianVec1 = median(logReturns1);
stdVec1 = std(logReturns1);
minVec1 = min(logReturns1);
maxVec1 = max(logReturns1);
Descriptives1 = table(meanVec1', medianVec1', stdVec1', minVec1', maxVec1','VariableNames', {'mean', 'median', 'std', 'min', 'max'});
sharperatio1 = (meanVec1-Descriptives1{end, 1})./stdVec1;
Descriptives1.sharperatio1 = sharperatio1'

%secondHalf
logReturns2 = diff(log(secondHalf{:,2:end}));
meanVec2 = mean(logReturns2) * 252;
medianVec2 = median(logReturns2);
stdVec2 = std(logReturns2);
minVec2 = min(logReturns2);
maxVec2 = max(logReturns2);
Descriptives2 = table(meanVec2', medianVec2', stdVec2', minVec2', maxVec2','VariableNames', {'mean', 'median', 'std', 'min', 'max'});
sharperatio2 = (meanVec2-Descriptives2{end, 1})./stdVec2;
Descriptives2.sharperatio2 = sharperatio2'
%% 7b. Comment 
% From the result of the two parts, we can see in general the second half
% of the year has a higher score than the first half of the year. This
% indicates the investment products have a higher return in the second half
% of the year compared to the first half. Therefore, if investors only want
% to invest for a few month with no special preference on products, they 
% should start from July or later.

% In the first half of the year, Gold has the higeest return of more than
% 11, which means it it generates return 11 times higher than the risk-free rate 
% per unit(standard deviation). The second high-return product is Bitcoin,
% which can generate return 10 times higher than the risk-free rate per 
% unit(standard deviation). Considering the standard deviation, Gold still
% has the lowest score which means it has the smallest risk. Therefore, if
% investors want to invest in the first half of the year, they should
% definitely choose Gold.

% In the second half of the year, ETF has the highest score of 14 which
% means it generates return 14 times higher than the risk-free rate per
% unit. The second high-return product is still Bitcoin and the return rate
% is 10 which is roughly the same as the first half and the whole year.
% However, Gold does not have a good performance in this period.

% In general, if investors want to invest for a few month and achieve a
% good return, they can invest EFT in the second hald of the year with some
% risk. Ot they invest Bitcoin or Gold before June. If they prefer less
% risk among these two products, Gold is their first choice. But it is not
% suggested to invest Gold after July, since it has less return.

% Compared to 6a, Gold is not the first choice in both periods. If
% investors prefer buying a long time product for a year with good return and less
% risk, they can choose Gold. But Bitcoin can be a good choice for both
% periods and the whole year, if investors are risk-preferred and want good
% return. EFT is only suggested in the second half of the year.
%% 8. Correlations and diversification
%% 8a. Pairwise correlations
logReturns = log_return
correlationMatrix = corrcoef(logReturns);
rowNames =  Data.Properties.VariableNames(2:end);
columnNames = Data.Properties.VariableNames(2:end);
correlationTable = array2table(correlationMatrix, 'RowNames', rowNames, 'VariableNames', columnNames);
%% 8b. Comment

%% 8c. Least correlated investments

%% 8d. Portfolio
investment1 = logReturns(:,6); %Gold
investment2 = logReturns(:,2); %BankOfAmerica
equalWeightedPortfolio = (investment1 + investment2) / 2;

meanPortfolio = mean(equalWeightedPortfolio) * 252;
stdPortfolio = std(equalWeightedPortfolio);
annualizedstdPortfolio = stdPortfolio * sqrt(252);

DescriptivesPortfolio = table(meanPortfolio', stdPortfolio','VariableNames', {'mean', 'std'});
sharperatioPortfolio = (meanPortfolio-Descriptives{end, 1})./stdPortfolio;
DescriptivesPortfolio.sharperatioPortfolio = sharperatioPortfolio'
%% 9. Diversification potential 
%% 9a. Find all possible combinations of 3 stocks 
combinations = nchoosek(rowNames, 3)
%% 9b. Maximum Sharpe ratio portfolio
portfolio = zeros(size(C, 1), 3);

for i = 1:size(C, 1)
    currentC = C(i, :);
    weights = ones(1, 3) / 3;
    portfolio_returns = mean(logReturns(:, currentC) * weights');
    portfolio_std = std(logReturns(:, currentC) * weights');
    sharpe_ratio = portfolio_returns / portfolio_std;
    portfolio_data(i, 1) = portfolio_returns;
    portfolio_data(i, 2) = portfolio_std;
    portfolio_data(i, 3) = sharpe_ratio;
end


%% 9c. Scatter plot

%% 9d. Comment
% Gold still has the lowest volatility score and Bitcoin has the highest,
% which means Gold is a safe choice while Bitcoin is risky. This is the
% same as individual opportunities.
