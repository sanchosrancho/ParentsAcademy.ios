//
//  CamRecorderViewController.m
//  ParentsAcademy
//
//  Created by Alex on 5/3/14.
//  Copyright (c) 2014 Alex Shevlyakov. All rights reserved.
//

#import "CamRecorderViewController.h"

@interface CamRecorderViewController ()
{
    NSTimer *recIconTimer;
}

@property (nonatomic, strong, readonly) CALayer *recordFlashingLayer;

@end

@implementation CamRecorderViewController

@synthesize recordFlashingLayer = _recordFlashingLayer;

- (void)viewDidUnload
{
	[super viewDidUnload];
	captureSession = nil;
	movieFileOutput = nil;
	deviceInput = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	isRecording = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRecording];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:NO];
}


//[self startRecording];
//[self toggleCameraPosition];
//[self stopRecording];


#pragma mark - Camera

- (void)initCamera
{
	captureSession = [[AVCaptureSession alloc] init];
	
    // init Inputs
	
	// adding video input
	AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (videoCaptureDevice) {
		NSError *error;
		deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
		if (!error && [captureSession canAddInput:deviceInput]) {
            [captureSession addInput:deviceInput];
		}
	}
	
	// adding audio input
	AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	NSError *error = nil;
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
	if (audioInput) {
		[captureSession addInput:audioInput];
	}
	
	
	// Init Outputs
	
	[self setVideoPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession]];
	[self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
	
	movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
	
	Float64 TotalSeconds = 60;
	int32_t preferredTimeScale = 30;
	CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
	movieFileOutput.maxRecordedDuration = maxDuration;
	
	movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
	
	if ([captureSession canAddOutput:movieFileOutput]) {
		[captureSession addOutput:movieFileOutput];
    }

	[self cameraSetOutputProperties];

	[captureSession setSessionPreset:AVCaptureSessionPresetMedium];
	if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
		[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }


    // Draw Video Layer
    
	CGRect layerRect = [[[self view] layer] bounds];
	[self.videoPreviewLayer setBounds:layerRect];
	[self.videoPreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
																  CGRectGetMidY(layerRect))];
	UIView *cameraView = [[UIView alloc] init];
	[self.view addSubview:cameraView];
	[self.view sendSubviewToBack:cameraView];
	
	[cameraView.layer addSublayer:self.videoPreviewLayer];
    [cameraView.layer addSublayer:self.recordFlashingLayer];
    
	[captureSession startRunning];
}

- (void)cameraSetOutputProperties
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
		
	//Set frame rate (if requried)
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
	
	if (CaptureConnection.supportsVideoMinFrameDuration) {
		CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FPS);
    }
	if (CaptureConnection.supportsVideoMaxFrameDuration) {
		CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FPS);
    }
	
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
	NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *Device in Devices) {
		if ([Device position] == position) {
			return Device;
		}
	}
	return nil;
}

- (void)toggleCameraPosition
{
	if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
    
		NSError *error;
		AVCaptureDeviceInput *newVideoInput;
		AVCaptureDevicePosition position = [[deviceInput device] position];
		if (position == AVCaptureDevicePositionBack) {
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&error];
		} else if (position == AVCaptureDevicePositionFront) {
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionBack] error:&error];
		}
        
		if (newVideoInput != nil) {
			
            [captureSession beginConfiguration];
			
            [captureSession removeInput:deviceInput];
			if ([captureSession canAddInput:newVideoInput]) {
				[captureSession addInput:newVideoInput];
				deviceInput = newVideoInput;
			} else {
				[captureSession addInput:deviceInput];
			}
			[self cameraSetOutputProperties];
			
			[captureSession commitConfiguration];
		}
        
	}
}

- (void)startRecording
{
    isRecording = YES;
    [self recordIconFlashing_start];

    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@%4.f%@", NSTemporaryDirectory(), @"camera-video-", [NSDate timeIntervalSinceReferenceDate], @".mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
            //Error handle if requried
        }
    }
    
    [movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

- (void)stopRecording
{
    isRecording = NO;
    [self recordIconFlashing_stop];
    [movieFileOutput stopRecording];
}

// didStartRecordingToOutputFileAtURL


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
	  fromConnections:(NSArray *)connections
				error:(NSError *)error
{
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    
	if (recordedSuccessfully) {
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]) {
			[library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                }
            }];
		}
	}
}


#pragma mark - Record Flashing

- (void)recordIconFlashing_start
{
    if (recIconTimer) return;
    
    recIconTimer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(recordIconFlashing_action:) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:recIconTimer forMode:NSDefaultRunLoopMode];
}

- (void)recordIconFlashing_action:(NSTimer*)timer
{
    self.recordFlashingLayer.opacity = !self.recordFlashingLayer.opacity;
}

- (void)recordIconFlashing_stop {
    [recIconTimer invalidate];
    recIconTimer = nil;
    self.recordFlashingLayer.opacity = 0;
}

- (CALayer *)recordFlashingLayer
{
    if (_recordFlashingLayer) return _recordFlashingLayer;
    
    _recordFlashingLayer = [CALayer layer];
    _recordFlashingLayer.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.3 alpha:0.9].CGColor;
    _recordFlashingLayer.frame = CGRectMake(self.view.frame.size.width - 16 - 24, 16, 24, 24);
    _recordFlashingLayer.cornerRadius = 12;
    _recordFlashingLayer.opacity = 0;
    return _recordFlashingLayer;
}

@end
