public class RCCTV2_Tuple {
//[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]
//this only a structure to handle the 4 RCCT values at once. Could be extended in the future to become a 
// a singleton containg RCCT state for current record to simplify SMB_XXX_RCCT_VFC controllers
    public string region{get;set;}
    public string cluster{get;set;}
    public string country{get;set;}
    public string territory{get;set;}
}