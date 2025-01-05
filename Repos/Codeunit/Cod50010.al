codeunit 50010 "Order Request Management"
{
    trigger OnRun()
    begin

    end;

    procedure SyncOrderRequestFromWeb()
    var
        CSVBuffer: Record "CSV Buffer" temporary;
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        InStream: InStream;
        OutStream: OutStream;
        FileName: Text;
        SheetName: Text;
    begin
        HttpRequestMessage.SetRequestUri('https://docs.google.com/spreadsheets/d/e/2PACX-1vQRrpjcg3Uv9KR-c4X8DoEPk-VclI6clfkK0C30Z4SrfvE-qS85DsKddEKyE6c3zvaEQ7KawfCb2CmT/pub?gid=1693383694&single=true&output=csv');
        HttpRequestMessage.Method := 'GET';

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(InStream);
                CSVBuffer.LoadDataFromStream(InStream, ',');

                if CSVBuffer.FindLast() then begin
                    Message('Rows count %1', CSVBuffer.Count);
                end;
            end;
        end;
    end;
}