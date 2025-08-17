permissionset 50010 "Order Request"
{
    Assignable = true;
    Caption = 'Order Request';
    Permissions = codeunit "Order Request Management" = X,
        page "Order Request" = X,
        page "Order Request Setup" = X,
        page "Order Request Dashboard" = X,
        table "Order Request" = X,
        table "Order Request Setup" = X,
        tabledata "Order Request" = RIMD,
        tabledata "Order Request Setup" = RIMD;
}