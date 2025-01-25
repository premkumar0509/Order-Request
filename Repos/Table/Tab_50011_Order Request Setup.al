table 50011 "Order Request Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Google Sheet URL"; Text[2048])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Excel Online URL"; Text[2048])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Use Default Cust. No. Series"; Boolean)
        {
            Caption = 'Use Default Customer No. Series';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if Rec."Use Default Cust. No. Series" <> XRec."Use Default Cust. No. Series" then
                    Rec."Customer No. Series" := '';
            end;
        }
        field(5; "Customer No. Series"; Code[20])
        {
            TableRelation = "No. Series".Code;
            DataClassification = ToBeClassified;
        }
        field(6; "Default Customer Posting Group"; Code[20])
        {
            TableRelation = "Customer Posting Group".Code;
            DataClassification = ToBeClassified;
        }
        field(7; "Default Gen Bus. Posting Group"; Code[20])
        {
            Caption = 'Default Gen. Business Posting Group';
            TableRelation = "Gen. Business Posting Group".Code;
            DataClassification = ToBeClassified;
        }
        field(36965; "Report Start Date"; Date)
        {
            Caption = 'Report Start Date';
            DataClassification = CustomerContent;
        }
        field(36966; "Report End Date"; Date)
        {
            Caption = 'Report End Date';
            DataClassification = CustomerContent;
        }
        field(36974; "Report Id"; Guid)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
        }
        field(36975; "Report Name"; Text[200])
        {
            Caption = 'Report Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}