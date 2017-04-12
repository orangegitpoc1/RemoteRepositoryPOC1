@isTest(SeeAllData=true)
public class TEK_UTL_CSV_Test {

    public class ParseTestException extends Exception {}

    public static testMethod void testParseCSV(){      

            
        //build some dummy CSV string
        string sStringCSV = 'L0,L1,L2,L3\n';
        sStringCSV += '0-0\n';
        sStringCSV += '1-0,1-1\n';
        sStringCSV += '2-0,2-1,2-2\n';
        sStringCSV += '3-0,"3-1",3-2\n';
        sStringCSV += '4-0,4-1\n';
        sStringCSV += '5-0,5-1,5-2\n';
        sStringCSV += '6-0,5-1\n';
        sStringCSV += '7-0\n';

        //create file outside of test so that it is not mixed with the test.start in term of mixed DML etc...
        string sFileName = 'Apex-Deploy-Test-TEK_UTL_CSV_Test.testParseCSV';
        Document d = new Document(); 
        d.Name = sFileName.replace(' ', '-') + '-' + datetime.now().formatGMT('yyyy-MM-dd\'-\'HH:mm'); 
        d.Body = Blob.valueOf(sStringCSV); 
        d.ContentType = 'text/plain';
        d.Type = 'csv';
        d.FolderId = UserInfo.getUserId();
        //insert d;

        // test itself
        Test.startTest();
        list<list<string>> listListCSV = TEK_UTL_CSV.parseCSV(d.body.toString(), true); //true ==> Skip header
        try {
            if (listListCSV == null)
            {
                system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 01: call returned a NULL listListCSV, ');
            } else
            {
                if (listListCSV.get(0) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 02a: null value on row listListCSV.get(0)');
                if (listListCSV.get(0).get(0) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 02b: null value on cell listListCSV.get(0).get(0)');
                system.assertEquals('0-0', listListCSV.get(0).get(0), 'Apex test TEK_UTL_CSV.parseCSV failed with Error 02c: listListCSV not equal to 0-0');
                                                                                           
                if (listListCSV.get(3) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 03a: null value on row listListCSV.get(3)');
                if (listListCSV.get(3).get(1) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 03b: null value on cell listListCSV.get(3).get(1)');
				system.assertEquals('"3-1"', listListCSV.get(3).get(1), 'Apex test TEK_UTL_CSV.parseCSV failed with Error 03c: ' + listListCSV.get(3).get(1) + ' not equal to 3-1');
                                                                           
                if (listListCSV.get(7) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 04a: null value on row listListCSV.get(3)');
                if (listListCSV.get(7).get(0) == null) system.assert(false, 'Apex test TEK_UTL_CSV.parseCSV failed with Error 04b: null value on cell listListCSV.get(7).get(0)');
				system.assertEquals('7-0', listListCSV.get(7).get(0), 'Apex test TEK_UTL_CSV.parseCSV failed with Error 04c: listListCSV not equal to 7-0');
            }
            
        } catch (Exception e) {
            throw new ParseTestException('Apex test TEK_UTL_CSV.parseCSV failed with Error 00. Catched error: ' + e);
        }
		test.stopTest();
    }
    
}