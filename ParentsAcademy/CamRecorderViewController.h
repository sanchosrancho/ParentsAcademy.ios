//
//  CamRecorderViewController.h
//  ParentsAcademy
//
//  Created by Alex on 5/3/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define CAPTURE_FPS 20

@interface CamRecorderViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>
{
    BOOL isRecording;
	AVCaptureSession *captureSession;
	AVCaptureMovieFileOutput *movieFileOutput;
	AVCaptureDeviceInput *deviceInput;
}

@property (retain) AVCaptureVideoPreviewLayer *videoPreviewLayer;

- (void)cameraSetOutputProperties;
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;

@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)switchCameraButtonTouched:(id)sender;

@end
