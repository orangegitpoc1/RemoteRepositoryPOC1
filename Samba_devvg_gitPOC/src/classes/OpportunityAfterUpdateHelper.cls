public class OpportunityAfterUpdateHelper {
    
    private static Boolean amountChangeCondition(Decimal newAmountValue, Decimal oldAmountValue)
    {
        return (((newAmountValue - oldAmountValue).abs()/oldAmountValue)*100).round(System.RoundingMode.CEILING) >= 
                                        Decimal.valueOf(System.Label.SMB_Threshold_Percentage_Variation_For_Amount_Value_on_Opportunity);
    }
    
    public static Boolean addchatterFeedOnAmountChange(Decimal newAmountValue, Decimal oldAmountValue)
    {
        if(newAmountValue == 0 || oldAmountValue == 0 || oldAmountValue == null){
            return true;
        }else if(amountChangeCondition(newAmountValue, oldAmountValue)){
            return true;
        }
        return false;
    }
    
    public static String getURL(){
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

}