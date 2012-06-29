//
//  TicketManager.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol TicketManagerDelegate;

@interface TicketManager : NSObject <SKPaymentTransactionObserver,SKProductsRequestDelegate, UIAlertViewDelegate>
{
    BOOL fProcessing;
}
- (void)inAppPurchase:(NSObject*)target action:(SEL)selector sender:(id)sender;
@property NSInteger availableTickets;
@property NSInteger usedTickets;

@property(retain) id<TicketManagerDelegate> delegate;

@property(retain) NSObject *iap_target;
@property SEL iap_selector;
@property(retain) id iap_sender;

@end


@protocol TicketManagerDelegate <NSObject>
- (void)didFinishTicketManagerInAppPurchase:(TicketManager*)ticketManager;
@end

