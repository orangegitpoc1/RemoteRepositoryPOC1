/*******************************************************
[14/11/04] Created by J. Hazebrouck 
[15/03/11] OLE W2.1 UST-01081/WIT-2045 Minor technical fix: add error process on line 39 to catch page called without proper opty as parameter
This code is used to select the bid approval level for the opportunity
If the bid approval level is not known, the user can move to the 'nivelette' page
*******************************************************/
public without sharing class SMBW2_OPP_ChooseRecordType_VFC {

    public Opportunity oppty{get;set;}
    public String oppId;
    public String opptyTypeValue = '';
    public List<RecordType> listOppType{get;set;}
    public Map<string,RecordType> rTDeveloperNameTorTMap = new Map<string,RecordType>();
    
    //Getting back the bid types and choose one by default
    public SMBW2_OPP_ChooseRecordType_VFC(ApexPages.StandardController controller){
        oppId = Apexpages.currentPage().getParameters().get('oppId');
        listOppType = new List<RecordType>();
        
        /*listOppType = [SELECT Id, Name, Description, DeveloperName FROM RecordType WHERE sObjectType ='Opportunity' AND isActive = true AND DeveloperName LIKE: 'SAMBA%' order by DeveloperName];
        oppty = [SELECT Id, Name, RecordtypeId, RecordType.Name, StageName FROM Opportunity WHERE Id =: oppId limit 1];
        opptyTypeValue = listOppType[2].Id;*/
        
        for(RecordType rt:[SELECT Id, Name, Description, DeveloperName FROM RecordType WHERE sObjectType ='Opportunity' AND isActive = true AND DeveloperName LIKE: 'SAMBA%']){
            rTDeveloperNameTorTMap.put(rt.DeveloperName,rt); //Holds RecordTypedeveloperName to RecordTypeId Mapping
        }
                
        //Creating the record type list in the correct order.
        listOppType.add(rTDeveloperNameTorTMap.get('Samba_DOA_Oppty'));
        listOppType.add(rTDeveloperNameTorTMap.get('Samba_Local_Opportunity'));
        listOppType.add(rTDeveloperNameTorTMap.get('Samba_default_Oppty'));
        
        //Iterating it again so if any other SAMBA record type is present or created in future will be appended to the present list.
        for(String rTdevName: rTDeveloperNameTorTMap.keySet()){
            if(rTdevName!= listOppType[0].DeveloperName && rTdevName!= listOppType[1].DeveloperName && rTdevName!= listOppType[2].DeveloperName)
            listOppType.add(rTDeveloperNameTorTMap.get(rTdevName));
        }
        
        opptyTypeValue = listOppType[1].Id;
        try
        {
            oppty = [SELECT Id, Name, RecordtypeId, RecordType.Name, StageName FROM Opportunity WHERE Id =: oppId limit 1];
        }
        catch (Exception e)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'oops!... Something went wrong, sorry for the inconvenience... This page can only be called from the opportunity creation page. \n'
                                                       + 'Please if possible make a screenshot including the address at the top of your browser and send it to your local administrator'
                                                       + ' with a short explanation of how you reached this screen (e.g.: what you were where doing which button you cliked)'
                                                       + ' so that we can try to improve the application. \n'
                                                       + ' This page was called with an invalid Opportunity Id [' 
                                                       + oppId 
                                                       +'] or from an invalid context.'
                                                       + '\n' + e));
        }

    }
    
    //Method used to change the opportunity bid type
    public pageReference saveOpp(){
        try{
            oppty = [SELECT Id, Name, RecordtypeId, RecordType.Name, StageName FROM Opportunity WHERE Id =: oppId limit 1];
            oppty.RecordTypeId = opptyTypeValue;
            //In case, bid type = 'simple' there is no Pre-qualification stage, so we change the stage to Qualification
            if(oppty.RecordTypeId == listOppType[0].Id && oppty.StageName == '1 Pre-qualification')
                {oppty.StageName = '2 Qualification';}
            
            update oppty;
            
            PageReference pageRef = new PageReference('/' + oppty.Id + '?retURL=%2F' + oppty.Id);
            return pageRef;
        }
        catch(exception ex){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Exception Error: ' + ex));
            return null;
        }
    }
    
    //Method to go back to the record page without changing bid type
    public pageReference cancelOpp(){
        PageReference pageRef = new PageReference('/' + oppty.Id + '?retURL=%2F' + oppty.Id);
        return pageRef;
    }
    
    //Method to go to the 'nivelette' page
    public pageReference nivelOpp(){
        PageReference pageRef = new PageReference('/apex/SMBW2_OPP_NivelBidType_VFP?oppId=' + oppty.Id);
        return pageRef;
    }
    
    //Creation of the bid type picklist used in the visualforce page
    public List<SelectOption> getItemsType() {
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType r : listOppType){
            options.add(new SelectOption(r.Id, r.Name));
        }
        return options;
    }


    // Translated record type description (sourced from custom setting since not translatable oob)
    public class RecTypeTranslateException extends Exception{}
    public List<SMB_OPP_RecType_Translate__c> getItemsTranslate() {
        List<SelectOption> options = new List<SelectOption>();
        list<SMB_OPP_RecType_Translate__c> listRecTypeTranslate = new list<SMB_OPP_RecType_Translate__c> ();
        try 
        {
            string sUserLanguage = userInfo.getLanguage().substring(0,2);
            if (!sUserLanguage.capitalize().equals('EN')) 
            {
                listRecTypeTranslate = [
                    select SMB_OPP_Label__c, SMB_OPP_Description__c
                    from SMB_OPP_RecType_Translate__c
                    where SMB_OPP_Language__c = :sUserLanguage
                    order by SMB_OPP_Label__c
                    LIMIT 99 //Plenty enough
                ];
            }
            if (listRecTypeTranslate.size() == 0) // nothing, Pull EN as default
            {
                listRecTypeTranslate = [
                    select SMB_OPP_Label__c, SMB_OPP_Description__c
                    from SMB_OPP_RecType_Translate__c
                    where SMB_OPP_Language__c = 'En'
                    order by SMB_OPP_Label__c
                    LIMIT 99 //Plenty enough
                ];
                
            } 
            if (listRecTypeTranslate.size() == 0) // still nothing, not good
            {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 
                   'Error 01 "Cannot find Opty Rec Type translation in custom setting SMB_OPP_RecType_Translate__c" '));   
                
            }
            //now build list to display to VFP
            for (SMB_OPP_RecType_Translate__c csRecTypeTranslate: listRecTypeTranslate)
            {
                options.add(new SelectOption(
                                     csRecTypeTranslate.SMB_OPP_Description__c
                                    ,csRecTypeTranslate.SMB_OPP_Label__c
                                    )
                           );
            }
        }
        catch (Exception e)
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 
                   'Error 02 "Cannot find Opty Rec Type translation in custom setting SMB_OPP_RecType_Translate__c" ' + e));   
        }
        //return options;
        return listRecTypeTranslate;
    }
    
    public String getOpptyTypeValue() {
        return opptyTypeValue;
    }
    
    public void setOpptyTypeValue(String typeValue) {
        this.OpptyTypeValue = typeValue;
    }
}