table 50010 "Order Request"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Item Variant"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Phone No."; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Email"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Preferred contact method"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Email,"Phone No.";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}