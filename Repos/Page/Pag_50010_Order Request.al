page 50010 "Order Request"
{
    ApplicationArea = All;
    Caption = 'Order Request';
    PageType = List;
    SourceTable = "Order Request";
    UsageCategory = Lists;
    // ModifyAllowed = false;
    // DeleteAllowed = false;
    // InsertAllowed = false;

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
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
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
                field("Preferred Contact Method"; Rec."Preferred Contact Method")
                {
                    ToolTip = 'Specifies the value of the Preferred contact method field.';
                }
                field("Order No."; Rec."Order No.")
                {
                    ToolTip = 'Specifies the value of the Order No. field.';
                    Editable = false;
                    trigger OnDrillDown();
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Order No.") then
                            Page.Run(Page::"Sales Order", SalesHeader);
                    end;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Order ID"; Rec."Order ID")
                {
                    ToolTip = 'Specifies the value of the Order ID field.';
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
                ToolTip = 'Executes the Sync Order Request action.';
                trigger OnAction()
                var
                    OrderRequestManagement: Codeunit "Order Request Management";
                begin
                    OrderRequestManagement.SyncOrderRequestFromWeb();
                end;
            }
            action("Make Order")
            {
                ApplicationArea = All;
                Image = MakeOrder;
                ToolTip = 'Executes the Make Order action.';
                trigger OnAction()
                var
                    OrderRequestManagement: Codeunit "Order Request Management";
                begin
                    OrderRequestManagement.MakeOrder(Rec);
                end;
            }
            action(Setup)
            {
                ApplicationArea = All;
                Image = Setup;
                RunObject = Page "Order Request Setup";
                ToolTip = 'Executes the Setup action.';
            }
        }
        area(Promoted)
        {
            actionref(SyncOrderRequest_Promoted; "Sync Order Request")
            {
            }
            actionref(MakeOrder_Promoted; "Make Order")
            {
            }
            actionref(Setup_Promoted; Setup)
            {
            }
        }
    }
}