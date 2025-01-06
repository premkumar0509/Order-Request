page 50010 "Order Request"
{
    ApplicationArea = All;
    Caption = 'Order Request';
    PageType = List;
    SourceTable = "Order Request";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Time stamp"; Rec."Time stamp")
                {
                    ToolTip = 'Specifies the value of the Time Stamp field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Item Variant"; Rec."Item Variant")
                {
                    ToolTip = 'Specifies the value of the Item Variant field.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the Email field.';
                }
                field("Preferred contact method"; Rec."Preferred Contact Method")
                {
                    ToolTip = 'Specifies the value of the Preferred contact method field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Sync Order Request")
            {
                ApplicationArea = All;
                Image = OutlookSyncFields;
                trigger OnAction()
                var
                    OrderRequestManagement: Codeunit "Order Request Management";
                begin
                    OrderRequestManagement.SyncOrderRequestFromWeb();
                end;
            }
        }
        area(Promoted)
        {
            actionref(SyncOrderRequest_Promoted; "Sync Order Request")
            {
            }
        }
    }
}