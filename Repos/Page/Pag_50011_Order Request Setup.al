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
                Caption = 'General';

                field("Form URL"; Rec."Form URL")
                {
                    ToolTip = 'Specifies the value of the Form URL field.';
                    ExtendedDatatype = URL;
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
}