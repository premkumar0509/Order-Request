page 50012 "Order Request Dashboard"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Order Request Dashboard';
    PageType = Card;

    layout
    {
        area(Content)
        {
            // usercontrol(BusinessChart; BusinessChart)
            // {
            //     ApplicationArea = All;
            //     trigger AddInReady()
            //     begin
            //         this.LoadBusinessChart();
            //     end;
            // }
            usercontrol(PowerBIAddin; PowerBIManagement)
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    this.InitializeEmbeddedAddin(CurrPage.PowerBIAddin, this.ReportId, this.ReportPageLbl);
                end;

                trigger ErrorOccurred(Operation: Text; ErrorText: Text)
                begin
                    this.ShowPowerBIErrorNotification(Operation, ErrorText);
                end;
            }
        }
    }


    actions
    {
        area(processing)
        {
            action(FullScreen)
            {
                ApplicationArea = All;
                Caption = 'Fullscreen';
                ToolTip = 'Shows the Power BI element as full screen.';
                Image = View;

                trigger OnAction()
                begin
                    CurrPage.PowerBIAddin.FullScreen();
                end;
            }
        }
        area(Promoted)
        {
            actionref(FullScreen_Promoted; FullScreen)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        OrderRequestSetup: Record "Order Request Setup";
    begin
        OrderRequestSetup.SetLoadFields("Report Id", "Report Name");
        OrderRequestSetup.Get();
        this.ReportId := OrderRequestSetup."Report Id";
        this.ReportPageLbl := OrderRequestSetup."Report Name";
    end;


    // local procedure LoadBusinessChart()
    // var
    //     TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;
    //     OrderRequest: Record "Order Request";
    //     i: Integer;
    // begin
    //     TempBusinessChartBuffer.Initialize();
    //     TempBusinessChartBuffer.AddMeasure('Quantity', 2, TempBusinessChartBuffer."Data Type"::Decimal, TempBusinessChartBuffer."Chart Type"::Pie.AsInteger());
    //     TempBusinessChartBuffer.SetXAxis('Customer Name', TempBusinessChartBuffer."Data Type"::String);
    //     if OrderRequest.FindSet() then
    //         repeat
    //             TempBusinessChartBuffer.AddColumn(OrderRequest."Customer Name");
    //             TempBusinessChartBuffer.SetValueByIndex(0, i, OrderRequest.Quantity);
    //             i += 1;
    //         until OrderRequest.Next() = 0;
    //     TempBusinessChartBuffer.UpdateChart(CurrPage.BusinessChart);
    // end;

    local procedure InitializeEmbeddedAddin(PowerBIManagement: ControlAddIn PowerBIManagement; pReportId: Guid;
                                                                   ReportPageTok: Text)
    var
        PowerBIServiceMgt: Codeunit "Power BI Service Mgt.";
        TypeHelper: Codeunit "Type Helper";
        PowerBIEmbedReportUrlTemplateTxt: Label 'https://app.powerbi.com/reportEmbed?reportId=%1', Locked = true;
    begin
        PowerBiServiceMgt.InitializeAddinToken(PowerBIManagement);
        PowerBIManagement.SetLocale(TypeHelper.GetCultureName());
        PowerBIManagement.SetSettings(false, true, ReportPageTok = '', false, false, false, true);
        PowerBIManagement.EmbedPowerBIReport(
            StrSubstNo(PowerBIEmbedReportUrlTemplateTxt, pReportId),
            pReportId,
            ReportPageTok);
    end;

    local procedure ShowPowerBIErrorNotification(ErrorCategory: Text; ErrorMessage: Text)
    var
        PowerBIContextSettings: Record "Power BI Context Settings";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        Notify: Notification;
        ErrorNotificationMsg: Label 'An error occurred while loading Power BI. Your Power BI embedded content might not work. Here are the error details: "%1: %2"', Comment = '%1: a short error code. %2: a verbose error message in english';
    begin
        Notify.Id := CreateGuid();
        Notify.Message(StrSubstNo(ErrorNotificationMsg, ErrorCategory, ErrorMessage));
        Notify.Scope := NotificationScope::LocalScope;
        NotificationLifecycleMgt.SendNotification(Notify, PowerBIContextSettings.RecordId());
    end;

    var
        ReportPageLbl: Text;
        ReportId: Guid;
}