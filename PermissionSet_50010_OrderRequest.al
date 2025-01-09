permissionset 50010 "All"
{
    Access = Internal;
    Assignable = true;
    Caption = 'All permissions', Locked = true;

    Permissions =
         codeunit "Order Request Management" = X,
         page "Order Request" = X,
         page "Order Request Setup" = X,
         table "Order Request" = X,
         table "Order Request Setup" = X,
         tabledata "Order Request" = RIMD,
         tabledata "Order Request Setup" = RIMD;
}