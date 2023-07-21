public class FinancialSummaryAPIResponseClass {
    
    public static APICallStatus updateResponseMethod(String getResponse,Id accountId)
    {
       
        FinancialSummaryResponseWrapper wrap = FinancialSummaryResponseWrapper.parse(getResponse);
            system.debug('wrap:::'+wrap);
            system.debug('entityEmailId:::'+wrap.result.CompanyInfo.entityEmailId);
            system.debug('entityId:::'+wrap.result.CompanyInfo.entityId);
            system.debug('regAddOfEntity:::'+wrap.result.CompanyInfo.regAddOfEntity);
            system.debug('registrationDateOfCompany:::'+wrap.result.CompanyInfo.registrationDateOfCompany);
            system.debug('entityName:::'+wrap.result.CompanyInfo.entityName);
        
        	APICallStatus apistatus = new APICallStatus();
            apistatus.status = 'SUCCESS';
            
            List<Financial_Summary__c> lstwithinSixMonthObj = new List<Financial_Summary__c>();
            List<Financial_Summary__c> lstexceedingSixMonthsObj = new List<Financial_Summary__c>();
            List<Financial_Summary__c> lstbalSheetObj = new List<Financial_Summary__c>();
            List<Financial_Summary__c> lstcashFlowStatObj = new List<Financial_Summary__c>();
            List<Financial_Summary__c> lstratAnalysisObj = new List<Financial_Summary__c>();
            List<Financial_Summary__c> lstincomeStateObj = new List<Financial_Summary__c>();
            
            String recordId;
            FinancialSummaryResponseWrapper.CompanyInfo detailsOfCompInfo = wrap.result.CompanyInfo;
            if(detailsOfCompInfo != null)
            {
                Financial_Summary__c finSummObj = new Financial_Summary__c();
                finSummObj.Name = 'Financial Summary Record';
                finSummObj.Customer__c = accountId;
                finSummObj.entityEmailId__c = detailsOfCompInfo.entityEmailId;
                finSummObj.entityId__c = detailsOfCompInfo.entityId;
                finSummObj.regAddOfEntity__c = detailsOfCompInfo.regAddOfEntity;
                finSummObj.Date_of_incorporation__c  = detailsOfCompInfo.registrationDateOfCompany;
                finSummObj.entityName__c = detailsOfCompInfo.entityName;
                if(finSummObj != null)
                {
                    insert finSummObj;
                	recordId = finSummObj.Id;
                }
                
            }
            
            
            List<FinancialSummaryResponseWrapper.StandAlone> detailsOfStandAlone = wrap.result.StandAlone;
            if(detailsOfStandAlone != null)
            {
                for(FinancialSummaryResponseWrapper.StandAlone lstStandAlone : detailsOfStandAlone)
                {
                    FinancialSummaryResponseWrapper.WithinSixMonths lstWithinSixMonth = lstStandAlone.DATA.TradeReceivables.WithinSixMonths;
                    
                    Financial_Summary__c withinSixMonthObj = new Financial_Summary__c();
                    withinSixMonthObj.Id = recordId;
                    withinSixMonthObj.doubtfulWithSix__c = String.valueOf(lstWithinSixMonth.doubtfulWithSix);
                    withinSixMonthObj.netTrdRecWithSix__c = String.valueOf(lstWithinSixMonth.netTrdRecWithSix);
                    withinSixMonthObj.debtsDueDirWithSix__c = String.valueOf(lstWithinSixMonth.debtsDueDirWithSix);
                    withinSixMonthObj.totTrdRecWithSix__c  = String.valueOf(lstWithinSixMonth.totTrdRecWithSix);
                    withinSixMonthObj.securedGoodWithSix__c = String.valueOf(lstWithinSixMonth.securedGoodWithSix);
                    withinSixMonthObj.unsecuredGoodWithSix__c  = String.valueOf(lstWithinSixMonth.unsecuredGoodWithSix);
                    withinSixMonthObj.provisionForBadAndDoubtfulDebtsWithSix__c  = String.valueOf(lstWithinSixMonth.provisionForBadAndDoubtfulDebtsWithSix);
                    
                    lstwithinSixMonthObj.add(withinSixMonthObj);
                    
                    
                    FinancialSummaryResponseWrapper.ExceedingSixMonths lstExceedingSixMonths = lstStandAlone.DATA.TradeReceivables.ExceedingSixMonths;
                    
                    Financial_Summary__c exceedingSixMonthsObj = new Financial_Summary__c();
                    exceedingSixMonthsObj.Id = recordId;
                    exceedingSixMonthsObj.netTrdRecExSix__c = String.valueOf(lstExceedingSixMonths.netTrdRecExSix);
                    exceedingSixMonthsObj.provisionForBadAndDoubtfulDebtsExSix__c = String.valueOf(lstExceedingSixMonths.provisionForBadAndDoubtfulDebtsExSix);
                    exceedingSixMonthsObj.debtsDueDirExSix__c = String.valueOf(lstExceedingSixMonths.debtsDueDirExSix);
                    exceedingSixMonthsObj.unsecuredGoodExSix__c  = String.valueOf(lstExceedingSixMonths.unsecuredGoodExSix);
                    exceedingSixMonthsObj.doubtfulExSix__c = lstExceedingSixMonths.doubtfulExSix;
                    exceedingSixMonthsObj.securedGoodExSix__c  = lstExceedingSixMonths.securedGoodExSix;
                    exceedingSixMonthsObj.totTrdRecExSix__c  = lstExceedingSixMonths.totTrdRecExSix;
                    
                    lstexceedingSixMonthsObj.add(exceedingSixMonthsObj);
                    
                    
                    FinancialSummaryResponseWrapper.BalSheet lstBalSheet = lstStandAlone.DATA.CurrentFinancialSummary.BalSheet;
                    
                    Financial_Summary__c balSheetObj = new Financial_Summary__c();
                    balSheetObj.Id = recordId;
                    balSheetObj.propertyPlantAndEquipment__c = lstBalSheet.propertyPlantAndEquipment;
                    balSheetObj.Share_Capital__c = lstBalSheet.shareCap;
                    balSheetObj.Reserves_And_Surplus__c  = lstBalSheet.otherEquity;
                    balSheetObj.Total_Equity_And_Liabilities__c  = lstBalSheet.totalEl;
                    balSheetObj.Deferred_Tax_Liablitiy__c = lstBalSheet.deffTaxLiab;
                    balSheetObj.Cash_And_Bank_Balance__c  = lstBalSheet.cashAndBank;
                    balSheetObj.Total_Borrowings__c  = lstBalSheet.totalBorr;
                    balSheetObj.Total_Assets__c  = lstBalSheet.totalAssets;
                    balSheetObj.Non_controlling_interest__c  = lstBalSheet.nonControllingInterest;
                    balSheetObj.Capital_Work_In_Progress__c  = lstBalSheet.capWip;
                    balSheetObj.Total_Investments__c  = lstBalSheet.investments;
                    balSheetObj.Other_Assets__c  = lstBalSheet.otherAssets;
                    balSheetObj.Other_Liabilities__c  = lstBalSheet.othersLiab;
                    
                    
                    lstbalSheetObj.add(balSheetObj);
                    
                    
                    FinancialSummaryResponseWrapper.CashFlowStat lstCashFlowStat = lstStandAlone.DATA.CurrentFinancialSummary.CashFlowStat;
                    
                    Financial_Summary__c cashFlowStatObj = new Financial_Summary__c();
                    cashFlowStatObj.Id = recordId;
                    cashFlowStatObj.cashAndCashEquivalentsCashFlowStatementA__c  = lstCashFlowStat.cashAndCashEquivalentsCashFlowStatementAtBeginningOfPeriod;
                    cashFlowStatObj.cashFlowsFromUsedInFinancingActivities__c = lstCashFlowStat.cashFlowsFromUsedInFinancingActivities;
                    cashFlowStatObj.cashFlowsFromUsedInInvestingActivities__c  = lstCashFlowStat.cashFlowsFromUsedInInvestingActivities;
                    cashFlowStatObj.Free_Cash_Flow__c  = lstCashFlowStat.freeCashFlow;
                    cashFlowStatObj.Capital_Expenditure__c = lstCashFlowStat.capExpenditure;
                    cashFlowStatObj.cash_flow_statement_at_end__c   = lstCashFlowStat.cashAndCashEquivalentsCashFlowStatementAtEndOfPeriod;
                    cashFlowStatObj.Net_increase_decrease_in_cash_and_cash__c    = lstCashFlowStat.increaseDecreaseInCashAndCashEquivalents;
                    cashFlowStatObj.cashFlowsFromUsedInOperatingActivities__c    = lstCashFlowStat.cashFlowsFromUsedInOperatingActivities;

                    lstcashFlowStatObj.add(cashFlowStatObj);
                    
                    
                    FinancialSummaryResponseWrapper.RatAnalysis lstRatAnalysis = lstStandAlone.DATA.CurrentFinancialSummary.RatAnalysis;
                    
                    Financial_Summary__c ratAnalysisObj = new Financial_Summary__c();
                    ratAnalysisObj.Id = recordId;
                    ratAnalysisObj.Return_On_Equity__c  = String.valueOf(lstRatAnalysis.returnOnEquity);
                    ratAnalysisObj.Net_Debt_To_Equity__c = String.valueOf(lstRatAnalysis.netDebtEquity);
                    ratAnalysisObj.Net_Profit_Margin__c  = String.valueOf(lstRatAnalysis.netProfitMargin);
                    ratAnalysisObj.Net_Operating_Income_Growth__c  = String.valueOf(lstRatAnalysis.netOpIncGrowth);
                    ratAnalysisObj.Net_Profit_Growth__c = lstRatAnalysis.netProfGrowth;
                    ratAnalysisObj.Return_On_Capital_Employed__c   = String.valueOf(lstRatAnalysis.roce);
                    ratAnalysisObj.Interest_Coverage__c    = String.valueOf(lstRatAnalysis.interestCoverage);
                    ratAnalysisObj.EBITDA_Margin__c    = String.valueOf(lstRatAnalysis.ebitdaMargin);
					ratAnalysisObj.EBITDA_Growth__c  = lstRatAnalysis.ebitdaGrowth;
                    
                    lstratAnalysisObj.add(ratAnalysisObj);
                    
                    FinancialSummaryResponseWrapper.IncomeState lstIncomeState = lstStandAlone.DATA.CurrentFinancialSummary.IncomeState;
                    
                    Financial_Summary__c incomeStateObj = new Financial_Summary__c();
                    incomeStateObj.Id = recordId;
                    incomeStateObj.Share_of_Associates_Joint_Ventures_and__c  = lstIncomeState.shareAssocJointVent;
                    incomeStateObj.Depreciation_And_Amortisation__c = lstIncomeState.deprcnAmort;
                    incomeStateObj.Total_Tax_Expense__c  = lstIncomeState.totalTaxExpense;
                    incomeStateObj.Total_Expenses__c  = lstIncomeState.totExp;
                    incomeStateObj.Exceptional_Items__c = lstIncomeState.exceptionalItemsBeforeTax;
                    incomeStateObj.Profit_Loss_Before_Tax__c   = lstIncomeState.profLossBefTax;
                    incomeStateObj.Other_Income__c    = lstIncomeState.otherIncome;
                    incomeStateObj.Profit_Loss_After_Tax__c    = lstIncomeState.profitLoss;
					incomeStateObj.Interest_Cost__c  = lstIncomeState.finCost;
                    incomeStateObj.Earnings_Before_Interest_Taxation__c  = lstIncomeState.ebit;
                    incomeStateObj.Effective_Tax_Rate__c  = String.valueOf(lstIncomeState.effTaxRate);
                    incomeStateObj.Earnings_Before_Interest_Depreciation__c  = lstIncomeState.ebitda;
                    incomeStateObj.Net_Operating_Income__c  = lstIncomeState.revenueFromOperations;
                    
                    lstincomeStateObj.add(incomeStateObj);
                }
                 
                if(lstwithinSixMonthObj.Size() >0)
                {
                    system.debug('lstwithinSixMonthObj:::'+lstwithinSixMonthObj);
                    system.debug('lstwithinSixMonthObj Size : ::'+lstwithinSixMonthObj.Size());
                    update lstwithinSixMonthObj;
                }
                if(lstexceedingSixMonthsObj.Size() >0)
                {
                    system.debug('lstexceedingSixMonthsObj:::'+lstexceedingSixMonthsObj);
                    system.debug('lstexceedingSixMonthsObj Size : ::'+lstexceedingSixMonthsObj.Size());
                    update lstexceedingSixMonthsObj;
                }
                if(lstbalSheetObj.Size() >0)
                {
                    system.debug('lstbalSheetObj:::'+lstbalSheetObj);
                    system.debug('lstbalSheetObj Size : ::'+lstbalSheetObj.Size());
                    update lstbalSheetObj;
                }
                if(lstcashFlowStatObj.Size() >0)
                {
                    system.debug('lstcashFlowStatObj:::'+lstcashFlowStatObj);
                    system.debug('lstcashFlowStatObj Size : ::'+lstcashFlowStatObj.Size());
                    update lstcashFlowStatObj;
                }
                if(lstratAnalysisObj.Size() >0)
                {
                    system.debug('lstratAnalysisObj:::'+lstratAnalysisObj);
                    system.debug('lstratAnalysisObj Size : ::'+lstratAnalysisObj.Size());
                    update lstratAnalysisObj;
                }
                if(lstincomeStateObj.Size() >0)
                {
                    system.debug('lstincomeStateObj:::'+lstincomeStateObj);
                    system.debug('lstincomeStateObj Size : ::'+lstincomeStateObj.Size());
                    update lstincomeStateObj;
                }
                
            }
           return apistatus;   
    }

}