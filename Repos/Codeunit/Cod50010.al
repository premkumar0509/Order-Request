codeunit 50010 "Order Request Management"
{

    trigger OnRun();
    begin
        SyncOrderRequestFromWeb();
    end;

    procedure SyncOrderRequestFromWeb()
    var
        CSVBuffer: Record "CSV Buffer" temporary;
        TypeHelper: Codeunit "Type Helper";
        OrderRequest: Record "Order Request";
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        InStream: InStream;
        LineNo: Integer;
        IsAlreadyExists: Boolean;
    begin
        HttpRequestMessage.SetRequestUri('https://docs.google.com/spreadsheets/d/e/2PACX-1vQRrpjcg3Uv9KR-c4X8DoEPk-VclI6clfkK0C30Z4SrfvE-qS85DsKddEKyE6c3zvaEQ7KawfCb2CmT/pub?gid=1693383694&single=true&output=csv');
        HttpRequestMessage.Method := 'GET';

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode() then begin
                HttpResponseMessage.Content().ReadAs(InStream);
                CSVBuffer.LoadDataFromStream(InStream, ',');

                for LineNo := 2 to CSVBuffer.GetNumberOfLines() do begin
                    OrderRequest.SetFilter("Time stamp", CSVBuffer.GetValue(LineNo, 1));
                    if OrderRequest.FindFirst() then
                        IsAlreadyExists := true;

                    if not IsAlreadyExists then begin
                        OrderRequest.Reset();
                        OrderRequest.Init();
                        OrderRequest."Entry No." := GetLastOrderRequestEntryNo() + 1;
                    end;
                    Evaluate(OrderRequest."Time stamp", CSVBuffer.GetValue(LineNo, 1));
                    OrderRequest."Customer No." := CSVBuffer.GetValue(LineNo, 3);
                    OrderRequest."Customer Name" := CSVBuffer.GetValue(LineNo, 4);
                    OrderRequest."Phone No." := CSVBuffer.GetValue(LineNo, 5);
                    OrderRequest.Email := CSVBuffer.GetValue(LineNo, 6);
                    if Format(OrderRequest."Preferred Contact Method"::"Phone No.") = CSVBuffer.GetValue(LineNo, 7) then
                        OrderRequest."Preferred Contact Method" := OrderRequest."Preferred Contact Method"::"Phone No.";
                    OrderRequest."Item No." := CSVBuffer.GetValue(LineNo, 8);
                    OrderRequest."Item Variant" := CSVBuffer.GetValue(LineNo, 9);

                    if not IsAlreadyExists then
                        OrderRequest.Insert()
                    else
                        OrderRequest.Modify();
                end;
            end;
        end;
    end;

    local procedure GetLastOrderRequestEntryNo(): Integer
    var
        OrderRequest: Record "Order Request";
    begin
        if OrderRequest.FindLast() then
            exit(OrderRequest."Entry No.");
        exit(0);
    end;



    local procedure GetValue(InputText: Text): Variant
    begin
        exit(InputText)
    end;
}