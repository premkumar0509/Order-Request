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
        field(5; "Item Description"; Text[100])
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
        field(9; "Order ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Submitted DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Status; Option)
        {
            OptionMembers = Open,Error,"Order Created";
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Order Confirmation Mail Sent"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Error Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Synced From"; Option)
        {
            OptionMembers = "Google Form","Microsoft Form";
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    trigger OnInsert();
    begin
        if Rec."Submitted DateTime" = 0DT then
            Rec."Submitted DateTime" := CurrentDateTime;
    end;
}