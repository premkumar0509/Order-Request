codeunit 50010 "Order Request Management"
{

    trigger OnRun();
    begin
        this.SyncOrderRequest();
    end;

    procedure SyncOrderRequest()
    begin
        this.SyncOrderRequestFromGoogleForm();
        this.SyncOrderRequestFromMicrosoftForm();
    end;

    local procedure SyncOrderRequestFromGoogleForm()
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
        OrderRequestSetup.TestField("Google Sheet URL");

        if not Client.Get(OrderRequestSetup."Google Sheet URL", APIResponse) then
            Error(GetLastErrorText());

        if APIResponse.IsSuccessStatusCode() then begin
            APIResponse.Content().ReadAs(InStream);
            TempCSVBuffer.LoadDataFromStream(InStream, ',');

            for LineNo := 2 to TempCSVBuffer.GetNumberOfLines() do begin
                Clear(IsAlreadyExists);
                OrderRequest.SetRange("Order ID", TempCSVBuffer.GetValue(LineNo, 9));
                OrderRequest.SetRange("Synced From", OrderRequest."Synced From"::"Google Form");
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
                OrderRequest."Item Description" := CopyStr(TempCSVBuffer.GetValue(LineNo, 7), 1, MaxStrLen(OrderRequest."Item Description"));
                OrderRequest."Order ID" := CopyStr(TempCSVBuffer.GetValue(LineNo, 9), 1, MaxStrLen(OrderRequest."Order ID"));
                OrderRequest."Synced From" := OrderRequest."Synced From"::"Google Form";

                Evaluate(OrderRequest."Submitted DateTime", TempCSVBuffer.GetValue(LineNo, 1));
                Evaluate(OrderRequest.Quantity, TempCSVBuffer.GetValue(LineNo, 8));

                if not IsAlreadyExists then
                    OrderRequest.Insert()
                else
                    OrderRequest.Modify();
            end;
        end;
    end;

    local procedure SyncOrderRequestFromMicrosoftForm()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        OrderRequest: Record "Order Request";
        OrderRequestSetup: Record "Order Request Setup";
        Client: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        APIResponse: HttpResponseMessage;
        InStream: InStream;
        RowNo, MaxRowNo : Integer;
        IsAlreadyExists: Boolean;
        SheetName: Text;
    begin
        OrderRequestSetup.Get();
        OrderRequestSetup.TestField("Excel Online URL");

        HttpRequestMessage.Method := 'GET';
        HttpRequestMessage.SetRequestUri(OrderRequestSetup."Excel Online URL");

        if not Client.Send(HttpRequestMessage, APIResponse) then
            Error(GetLastErrorText());

        if APIResponse.IsSuccessStatusCode() then begin
            APIResponse.Content().ReadAs(InStream);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(InStream);

            TempExcelBuffer.OpenBookStream(InStream, SheetName);
            TempExcelBuffer.ReadSheet();
            if TempExcelBuffer.FindLast() then
                MaxRowNo := TempExcelBuffer."Row No.";

            for RowNo := 2 to MaxRowNo do begin
                OrderRequest.SetRange("Order ID", this.GetValueAtCell(TempExcelBuffer, RowNo, 9));
                OrderRequest.SetRange("Synced From", OrderRequest."Synced From"::"Google Form");
                if OrderRequest.FindFirst() then
                    IsAlreadyExists := true;

                if not IsAlreadyExists then begin
                    OrderRequest.Reset();
                    OrderRequest.Init();
                    OrderRequest."Entry No." := GetLastOrderRequestEntryNo() + 1;
                end;

                OrderRequest."Customer No." := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 3), 1, MaxStrLen(OrderRequest."Customer No."));
                OrderRequest."Customer Name" := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 4), 1, MaxStrLen(OrderRequest."Customer Name"));
                OrderRequest."Phone No." := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 5), 1, MaxStrLen(OrderRequest."Phone No."));
                OrderRequest.Email := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 6), 1, MaxStrLen(OrderRequest.Email));
                OrderRequest."Item Description" := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 7), 1, MaxStrLen(OrderRequest."Item Description"));
                OrderRequest."Order ID" := CopyStr(this.GetValueAtCell(TempExcelBuffer, RowNo, 9), 1, MaxStrLen(OrderRequest."Order ID"));
                OrderRequest."Synced From" := OrderRequest."Synced From"::"Microsoft Form";

                Evaluate(OrderRequest."Submitted DateTime", this.GetValueAtCell(TempExcelBuffer, RowNo, 1));
                Evaluate(OrderRequest.Quantity, this.GetValueAtCell(TempExcelBuffer, RowNo, 8));

                if not IsAlreadyExists then
                    OrderRequest.Insert()
                else
                    OrderRequest.Modify();
            end;
        end;
    end;

    local procedure GetValueAtCell(TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;


    procedure MakeOrder(var OrderRequest: Record "Order Request")
    var
        OrderRequestSetup: Record "Order Request Setup";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
    begin
        // Check if customer exists
        if not Customer.Get(OrderRequest."Customer No.") then begin
            OrderRequestSetup.Get();
            OrderRequestSetup.TestField("Default Customer Posting Group");
            OrderRequestSetup.TestField("Default Gen Bus. Posting Group");

            Customer.Init();
            if not OrderRequestSetup."Use Default Cust. No. Series" then begin
                OrderRequestSetup.TestField("Customer No. Series");
                Customer."No." := NoSeries.GetNextNo(OrderRequestSetup."Customer No. Series");
            end;

            Customer.Name := OrderRequest."Customer Name"; // Set customer name
            Customer."Phone No." := OrderRequest."Phone No."; // Set phone number
            Customer."E-Mail" := OrderRequest.Email; // Set email
            Customer.Validate("Customer Posting Group", OrderRequestSetup."Default Customer Posting Group"); // Set email
            Customer.Validate("Gen. Bus. Posting Group", OrderRequestSetup."Default Gen Bus. Posting Group");
            Customer.Insert(true);
        end;

        // Initialize Sales Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);

        // Initialize Sales Line
        Item.SetRange(Description, OrderRequest."Item Description");
        if not Item.FindFirst() then
            Error('Item %1 not found.', OrderRequest."Item Description");

        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, OrderRequest.Quantity); // Set quantity
        SalesLine.Insert(true);

        OrderRequest."Customer No." := Customer."No.";
        OrderRequest."Order No." := SalesHeader."No.";
        OrderRequest."Item No." := Item."No.";
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

    procedure SendOrderConfirmationMail()
    var
        CompanyInformation: Record "Company Information";
        OrderRequest: Record "Order Request";
        EmailMessage: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        BodyMessage: Text;
        Recipients: List of [Text];
        SubjectLbl: Label 'Order Confirmation - %1', Comment = '%1 - Order No.';
    begin
        CompanyInformation.SetLoadFields(Name);
        CompanyInformation.Get();

        OrderRequest.SetFilter("Order No.", '<>%1', '');
        OrderRequest.SetRange("Order Confirmation Mail Sent", false);
        if OrderRequest.FindSet() then
            repeat
                Clear(Recipients);
                Clear(EmailMessage);
                Recipients.Add(OrderRequest.Email);
                BodyMessage := '<!DOCTYPE html>';
                BodyMessage += '     <html lang = "en" >';
                BodyMessage += '<head >';
                BodyMessage += '<meta charset = "UTF-8" >';
                BodyMessage += ' <meta name = "viewport" content = "width=device-width, initial-scale=1.0" >';
                BodyMessage += ' <title > Order Confirmation </title >';
                BodyMessage += '  <style >';
                BodyMessage += '    body {';
                BodyMessage += '       font - family: Arial, sans - serif;';
                BodyMessage += '          background - color: #f9f9f9;';
                BodyMessage += '       margin: 0;';
                BodyMessage += '          padding: 0;';
                BodyMessage += '    }';
                BodyMessage += '    .container {';
                BodyMessage += '      max - width: 600px;';
                BodyMessage += '   margin: 0 auto;';
                BodyMessage += 'background - color: #ffffff;';
                BodyMessage += '       padding: 20px;';
                BodyMessage += '   border: 1px solid #e0e0e0;';
                BodyMessage += '   border: 1px solid #e0e0e0;';
                BodyMessage += '     }';
                BodyMessage += '    .header {';
                BodyMessage += '       text-align: center;';
                BodyMessage += '        padding-bottom: 10px;';
                BodyMessage += '    }';
                BodyMessage += '    .header img {';
                BodyMessage += '       max-width: 50px;';
                BodyMessage += '      display: block;';
                BodyMessage += '      margin: 0 auto;';
                BodyMessage += '  }';
                BodyMessage += '   .content {';
                BodyMessage += '      font-size: 16px;';
                BodyMessage += '        line-height: 1.5;';
                BodyMessage += '   }';
                BodyMessage += '  .content p {';
                BodyMessage += '       margin: 0 0 10px;';
                BodyMessage += '    }';
                BodyMessage += '   .content .code {';
                BodyMessage += '       font-size: 24px;';
                BodyMessage += '       font-weight: bold;';
                BodyMessage += '       margin: 20px 0;';
                BodyMessage += '}';
                BodyMessage += '   .footer {';
                BodyMessage += '       font-size: 12px;';
                BodyMessage += '       color: #888888;';
                BodyMessage += '       text-align: center;';
                BodyMessage += '       margin-top: 20px;';
                BodyMessage += '   }';
                BodyMessage += '   .footer a {';
                BodyMessage += '       color: #888888;';
                BodyMessage += '       text-decoration: none;';
                BodyMessage += '   }';
                BodyMessage += '  </style>';
                BodyMessage += '</head>';
                BodyMessage += '<body>';
                BodyMessage += '<div class="container">';
                BodyMessage += '    <div class="header">';
                BodyMessage += '        <img src="https://1drv.ms/i/c/1B1AF90AD16E7D18/IQTk-gmW-hERTIKBzARukeAHAT4mzUtAmCDV7WszSyUFhl0" alt="Order Confirmation">';
                BodyMessage += '    </div>';
                BodyMessage += '    <div class="content">';
                BodyMessage += '        <p>Hi ' + OrderRequest."Customer Name" + ',</p > ';
                BodyMessage += '   <p>Thank you for your purchase! Your order has been successfully placed.</p>';
                BodyMessage += '<p>Your order confirmation No is:</p>';
                BodyMessage += '<p class="code">' + OrderRequest."Order No." + '</p>';
                BodyMessage += '<p > Your customer number is:';
                BodyMessage += '</p > <p class = "code" >' + OrderRequest."Customer No." + ' </p >';
                BodyMessage += '<p>If you have any questions or need assistance, please feel free to contact our support team</a>.</p>';
                BodyMessage += '    <p > Sincerely,</p >';
                BodyMessage += '<p > ' + CompanyInformation.Name + ' </p >';
                BodyMessage += '    </div>';
                BodyMessage += '    <div class="footer">';
                BodyMessage += '        <p>Copyright Xmind Ltd. All rights reserved.</p>';
                BodyMessage += '        <p>This is an auto-generated e-mail, and please do not reply.</p>';
                BodyMessage += '    </div>';
                BodyMessage += '</div>';
                BodyMessage += '</body>';
                BodyMessage += '</html >';

                Emailmessage.Create(Recipients, StrSubstNo(SubjectLbl, OrderRequest."Order No."), BodyMessage, true);

                if EmailSend.Send(Emailmessage, Enum::"Email scenario"::Default) then
                    OrderRequest."Order Confirmation Mail Sent" := true
                else begin
                    OrderRequest."Error Message" := 'Error sending email - %1' + CopyStr(GetLastErrorText(), 1, 200);
                    OrderRequest.Status := OrderRequest.Status::Error;
                end;
                OrderRequest.Modify();
            until OrderRequest.Next() = 0;
    end;

}