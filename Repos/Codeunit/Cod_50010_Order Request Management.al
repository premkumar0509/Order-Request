codeunit 50010 "Order Request Management"
{

    trigger OnRun();
    begin
        this.SyncOrderRequestFromWeb();
    end;

    procedure SyncOrderRequestFromWeb()
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        OrderRequest: Record "Order Request";
        OrderRequestSetup: Record "Order Request Setup";
        Client: HttpClient;
        APIResponse: HttpResponseMessage;
        InStream: InStream;
        LineNo: Integer;
        IsAlreadyExists: Boolean;
    begin
        OrderRequestSetup.Get();
        OrderRequestSetup.TestField("Form URL");

        if not Client.Get(OrderRequestSetup."Form URL", APIResponse) then
            Error(GetLastErrorText());

        if APIResponse.IsSuccessStatusCode() then begin
            APIResponse.Content().ReadAs(InStream);
            TempCSVBuffer.LoadDataFromStream(InStream, ',');

            for LineNo := 2 to TempCSVBuffer.GetNumberOfLines() do begin
                OrderRequest.SetFilter("Time stamp", TempCSVBuffer.GetValue(LineNo, 1));
                if OrderRequest.FindFirst() then
                    IsAlreadyExists := true;

                if not IsAlreadyExists then begin
                    OrderRequest.Reset();
                    OrderRequest.Init();
                    OrderRequest."Entry No." := GetLastOrderRequestEntryNo() + 1;
                end;

                OrderRequest."Customer No." := CopyStr(TempCSVBuffer.GetValue(LineNo, 3), 1, MaxStrLen(OrderRequest."Customer No."));
                OrderRequest."Customer Name" := CopyStr(TempCSVBuffer.GetValue(LineNo, 4), 1, MaxStrLen(OrderRequest."Customer Name"));
                OrderRequest."Phone No." := CopyStr(TempCSVBuffer.GetValue(LineNo, 5), 1, MaxStrLen(OrderRequest."Phone No."));
                OrderRequest.Email := CopyStr(TempCSVBuffer.GetValue(LineNo, 6), 1, MaxStrLen(OrderRequest.Email));
                OrderRequest."Item No." := CopyStr(TempCSVBuffer.GetValue(LineNo, 7), 1, MaxStrLen(OrderRequest."Item No."));

                Evaluate(OrderRequest."Time stamp", TempCSVBuffer.GetValue(LineNo, 1));
                Evaluate(OrderRequest.Quantity, TempCSVBuffer.GetValue(LineNo, 8));

                if not IsAlreadyExists then
                    OrderRequest.Insert()
                else
                    OrderRequest.Modify();
            end;
        end;
    end;

    procedure MakeOrder(OrderRequest: Record "Order Request")
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // Check if customer exists
        if not Customer.Get(OrderRequest."Customer No.") then begin
            Customer.Init();
            Customer."No." := OrderRequest."Customer No.";
            Customer.Name := OrderRequest."Customer Name"; // Set customer name 
            Customer."Phone No." := OrderRequest."Phone No."; // Set phone number 
            Customer."E-Mail" := OrderRequest.Email; // Set email 
            Customer."Customer Posting Group" := 'DOMESTIC'; // Set email 
            Customer."Gen. Bus. Posting Group" := 'DOMESTIC';
            Customer.Insert(true);
        end;

        // Initialize Sales Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", OrderRequest."Customer No.");
        SalesHeader.Insert(true);

        // Initialize Sales Line
        Item.Get(OrderRequest."Item No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, OrderRequest.Quantity); // Set quantity
        SalesLine.Insert(true);

        OrderRequest."Order No." := SalesHeader."No.";
        OrderRequest.Status := OrderRequest.Status::"Order Created";
        OrderRequest.Modify();
        Message('Order %1 has been created.', SalesHeader."No.");
    end;


    local procedure GetLastOrderRequestEntryNo(): Integer
    var
        OrderRequest: Record "Order Request";
    begin
        if OrderRequest.FindLast() then
            exit(OrderRequest."Entry No.");
        exit(0);
    end;
}