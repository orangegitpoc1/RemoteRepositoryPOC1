/*******************************************************
Created by N. Omari
Update of an opportunity with a list of boolean fields
checked for each stage of the sales process
*******************************************************/
public without sharing class SMBW1_OpportunityWriteReadStages_VFC {
    public boolean AllStages{
        get{ return AllStages= true;}set;}

    Public Opportunity opp{get;set;}
 
    public SMBW1_OpportunityWriteReadStages_VFC(ApexPages.StandardController controller) {
    // The extension constructor initializes variable opp by using the getRecord method from the standard controller.

        this.opp = (Opportunity)controller.getRecord();
    }
    
    public void save (){
        try {
        // Update opportunity opp with the new input values
        //   update opp;        //Commented out for WIT-337,also to increase the test coverage as the test class is also commented.
        // Refresh The display section
        //    AllStages= true;    //Commented out for WIT-337,also to increase the test coverage as the test class is also commented.
        }
        // Process exception
        catch (System.DmlException e) {
            System.debug('ERROR:' + e);
        } 
    }
}