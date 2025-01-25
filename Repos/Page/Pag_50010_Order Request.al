page 50010 "Order Request"
{
    ApplicationArea = All;
    Caption = 'Order Request';
    PageType = List;
    SourceTable = "Order Request";
    UsageCategory = Lists;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;

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
                field("Submitted DateTime"; Rec."Submitted DateTime")
                {
                    ToolTip = 'Specifies the value of the Submitted DateTime field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    Editable = false;
                    trigger OnDrillDown();
                    var
                        Customer: Record Customer;
                    begin
                        if Customer.Get(Rec."Customer No.") then
                            Page.Run(Page::"Customer Card", Customer);
                    end;
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
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the Email field.';
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
                field("Order Confirmation Mail Sent"; Rec."Order Confirmation Mail Sent")
                {
                    ToolTip = 'Specifies the value of the Order Confirmation Mail Sent field.';
                    StyleExpr = this.StatusStyle;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    StyleExpr = this.StatusStyle;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field.';
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
                    OrderRequestManagement.SyncOrderRequest();
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
            action("Send Mail")
            {
                ApplicationArea = All;
                Image = SendMail;
                ToolTip = 'Executes the Send Mail action.';
                trigger OnAction()
                var
                    OrderRequestManagement: Codeunit "Order Request Management";
                begin
                    OrderRequestManagement.SendOrderConfirmationMail();
                end;
            }
            action(Setup)
            {
                ApplicationArea = All;
                Image = Setup;
                RunObject = Page "Order Request Setup";
                ToolTip = 'Executes the Setup action.';
            }
            action(Dashboard)
            {
                ApplicationArea = All;
                Image = SelectChart;
                RunObject = Page "Order Request Dashboard";
                ToolTip = 'Executes the Dashboard action.';
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
            actionref(SendMail_Promoted; "Send Mail")
            {
            }
            actionref(Setup_Promoted; Setup)
            {
            }
            actionref(Dashboard_Promoted; Dashboard)
            {
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        this.StatusStyle := this.GetStatusStyle();
    end;

    local procedure GetStatusStyle(): Text
    begin
        case Rec.Status of
            Rec.Status::Open:
                exit('Strong');
            Rec.Status::"Order Created":
                exit('Favorable');
            Rec.Status::Error:
                exit('Unfavorable')
        end;
    end;

    var
        StatusStyle: Text;
}