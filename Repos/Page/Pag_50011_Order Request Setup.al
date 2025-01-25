page 50011 "Order Request Setup"
{
    ApplicationArea = All;
    UsageCategory = Documents;
    Caption = 'Order Request Setup';
    PageType = Card;
    SourceTable = "Order Request Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Google Form URL"; Rec."Google Sheet URL")
                {
                    ToolTip = 'Specifies the value of the Google Form URL field.';
                    ExtendedDatatype = URL;
                }
                field("Microsoft Form URL"; Rec."Excel Online URL")
                {
                    ToolTip = 'Specifies the value of the Microsoft Form URL field.';
                    ExtendedDatatype = URL;
                }

            }
            group(Customer)
            {
                field("Use Default Cust. No. Series"; Rec."Use Default Cust. No. Series")
                {
                    ToolTip = 'Specifies the value of the Use Default Cust. No. Series field.';
                }
                field("Default Customer Posting Group"; Rec."Default Customer Posting Group")
                {
                    ToolTip = 'Specifies the value of the Default Customer Posting Group field.';
                }
                field("Customer No. Series"; Rec."Customer No. Series")
                {
                    Editable = not Rec."Use Default Cust. No. Series";
                    ToolTip = 'Specifies the value of the Customer No. Series field.';
                }
                field("Default Gen Bus. Posting Group"; Rec."Default Gen Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Default Gen Bus. Posting Group field.';
                }
            }
            group(OrderRequestReport)
            {
                Caption = 'Order Request Report';
                group(OrderRequestGeneral)
                {
                    ShowCaption = false;
                    field("Report Name"; Format(Rec."Report Name"))
                    {
                        ApplicationArea = All;
                        Caption = 'Power BI Order Request Report';
                        ToolTip = 'Specifies the Order Request Report Name';

                        trigger OnAssistEdit()
                        begin
                            this.EnsureUserAcceptedPowerBITerms();
                            this.LookupPowerBIReport(Rec."Report ID", Rec."Report Name");
                        end;
                    }
                }
                field("Report Start Date"; Rec."Report Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the start date for Order Request report filter.';
                }
                field("Report End Date"; Rec."Report End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the end date for Order Request report filter.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;


    local procedure EnsureUserAcceptedPowerBITerms()
    var
        PowerBIContextSettings: Record "Power BI Context Settings";
        PowerBIEmbedSetupWizard: Page "Power BI Embed Setup Wizard";
        PowerBiNotSetupErr: Label 'Power BI is not set up. You need to set up Power BI in order to continue.';
    begin
        PowerBIContextSettings.SetRange(UserSID, UserSecurityId());
        if PowerBIContextSettings.IsEmpty() then begin
            PowerBIEmbedSetupWizard.SetContext('');
            if PowerBIEmbedSetupWizard.RunModal() <> Action::OK then;

            if PowerBIContextSettings.IsEmpty() then
                Error(PowerBiNotSetupErr);
        end;
    end;

    procedure LookupPowerBIReport(var ReportId: Guid; var ReportName: Text[200]): Boolean
    var
        WorkspaceId: Guid;
        WorkspaceName: Text[200];
    begin
        if LookupPowerBIWorkspace(WorkspaceId, WorkspaceName) then
            if LookupPowerBIReport(WorkspaceId, WorkspaceName, ReportId, ReportName) then
                exit(true);
    end;

    local procedure LookupPowerBIWorkspace(var WorkspaceId: Guid; var WorkspaceName: Text[200]): Boolean
    var
        TempPowerBISelectionElement: Record "Power BI Selection Element" temporary;
        PowerBIWorkspaceMgt: Codeunit "Power BI Workspace Mgt.";
    begin
        PowerBIWorkspaceMgt.AddSharedWorkspaces(TempPowerBISelectionElement);
        TempPowerBISelectionElement.SetRange(Type, TempPowerBISelectionElement.Type::Workspace);
        if not IsNullGuid(WorkspaceId) then begin
            TempPowerBISelectionElement.SetRange(ID, WorkspaceId);
            if TempPowerBISelectionElement.FindFirst() then;
            TempPowerBISelectionElement.SetRange(ID);
        end;
        if Page.RunModal(Page::"Power BI Selection Lookup", TempPowerBISelectionElement) = Action::LookupOK then begin
            WorkspaceId := TempPowerBISelectionElement.ID;
            WorkspaceName := TempPowerBISelectionElement.Name;
            exit(true);
        end;
    end;

    local procedure LookupPowerBIReport(WorkspaceId: Guid; WorkspaceName: Text[200]; var ReportId: Guid; var ReportName: Text[200]): Boolean
    var
        TempPowerBISelectionElement: Record "Power BI Selection Element" temporary;
        PowerBIWorkspaceMgt: Codeunit "Power BI Workspace Mgt.";
    begin
        PowerBIWorkspaceMgt.AddReportsForWorkspace(TempPowerBISelectionElement, WorkspaceId, WorkspaceName);
        TempPowerBISelectionElement.SetRange(Type, TempPowerBISelectionElement.Type::Report);
        if not IsNullGuid(ReportId) then begin
            TempPowerBISelectionElement.SetRange(ID, ReportId);
            if TempPowerBISelectionElement.FindFirst() then;
            TempPowerBISelectionElement.SetRange(ID);
        end;
        if Page.RunModal(Page::"Power BI Selection Lookup", TempPowerBISelectionElement) = Action::LookupOK then begin
            ReportId := TempPowerBISelectionElement.ID;
            ReportName := TempPowerBISelectionElement.Name;
            exit(true);
        end;
    end;

}