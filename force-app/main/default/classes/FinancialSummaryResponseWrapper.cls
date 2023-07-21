public class FinancialSummaryResponseWrapper {

    public String statusCode{get;set;}
    public String requestId{get;set;}     
	public result result{get;set;}
    
	public class result{
		public CompanyInfo companyInfo{get;set;}
        public StandAlone[] standAlone{get;set;}
	}
    
    public class CompanyInfo{
        public string entityEmailId{get;set;}
        public string entityId{get;set;}
        public string regAddOfEntity{get;set;}
        public string registrationDateOfCompany{get;set;}
        public string entityName{get;set;}

    }
    
    public class StandAlone{
        public DATA data{get;set;}
    }
    
    public class DATA{
        public TradeReceivables tradeReceivables{get;set;}
        public CurrentFinancialSummary currentFinancialSummary{get;set;}
    }
    
    public class TradeReceivables{
    	public WithinSixMonths withinSixMonths{get;set;}
        public ExceedingSixMonths exceedingSixMonths{get;set;}
    }
    
    public class WithinSixMonths{
        public Decimal doubtfulWithSix{get;set;}
        public Decimal netTrdRecWithSix{get;set;}
        public Decimal debtsDueDirWithSix{get;set;}
        public Decimal totTrdRecWithSix{get;set;}
        public Decimal securedGoodWithSix{get;set;}
        public Decimal unsecuredGoodWithSix{get;set;}
        public string provisionForBadAndDoubtfulDebtsWithSix{get;set;}
    }
    
    public class ExceedingSixMonths{
        public Decimal netTrdRecExSix{get;set;}
        public Decimal provisionForBadAndDoubtfulDebtsExSix{get;set;}
        public Decimal debtsDueDirExSix{get;set;}
        public Decimal unsecuredGoodExSix{get;set;}
        public Decimal doubtfulExSix{get;set;}
        public Decimal securedGoodExSix{get;set;}
        public Decimal totTrdRecExSix{get;set;}
    }
    public class CurrentFinancialSummary{
        public BalSheet balSheet{get;set;}
        public CashFlowStat cashFlowStat{get;set;}
        public RatAnalysis ratAnalysis{get;set;}
        public IncomeState incomeState{get;set;}
    }
    
    public class BalSheet{
        public Decimal propertyPlantAndEquipment{get;set;}
        public Decimal shareCap{get;set;}
        public Decimal otherEquity{get;set;}
        public Decimal totalEl{get;set;}
        public Decimal deffTaxLiab{get;set;}
        public Decimal cashAndBank{get;set;}
        public Decimal totalBorr{get;set;}
        public Decimal totalAssets{get;set;}
        public Decimal nonControllingInterest{get;set;}
        public Decimal capWip{get;set;}
        public Decimal investments{get;set;}
        public Decimal otherAssets{get;set;}
        public Decimal othersLiab{get;set;}

    }
    public class CashFlowStat{
        public string cashAndCashEquivalentsCashFlowStatementAtBeginningOfPeriod{get;set;}
        public string cashFlowsFromUsedInFinancingActivities{get;set;}
        public string cashFlowsFromUsedInInvestingActivities{get;set;}
        public Decimal freeCashFlow{get;set;}
        public Decimal capExpenditure{get;set;}
        public string cashAndCashEquivalentsCashFlowStatementAtEndOfPeriod{get;set;}
        public string increaseDecreaseInCashAndCashEquivalents{get;set;}
        public string cashFlowsFromUsedInOperatingActivities{get;set;}

    }
    public class RatAnalysis{
        public Decimal returnOnEquity{get;set;}
        public Decimal netDebtEquity{get;set;}
        public Decimal netProfitMargin{get;set;}
        public Decimal netOpIncGrowth{get;set;}
        public string netProfGrowth{get;set;}
        public Decimal roce{get;set;}
        public Decimal interestCoverage{get;set;}
        public Decimal ebitdaMargin{get;set;}
        public string ebitdaGrowth{get;set;}

    }
    public class IncomeState{
        public Decimal shareAssocJointVent{get;set;}
        public Decimal deprcnAmort{get;set;}
        public Decimal totalTaxExpense{get;set;}
        public Decimal totExp{get;set;}
        public Decimal exceptionalItemsBeforeTax{get;set;}
        public Decimal profLossBefTax{get;set;}
        public Decimal otherIncome{get;set;}
        public Decimal profitLoss{get;set;}
        public Decimal finCost{get;set;}
        public Decimal ebit{get;set;}
        public Decimal effTaxRate{get;set;}
        public Decimal ebitda{get;set;}
        public Decimal revenueFromOperations{get;set;}

    }
    
    public static FinancialSummaryResponseWrapper parse(String json){
		return (FinancialSummaryResponseWrapper) System.JSON.deserialize(json, FinancialSummaryResponseWrapper.class);
	}
}