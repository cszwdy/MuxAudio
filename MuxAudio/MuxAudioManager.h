//
//  MuxAudioManager.h
//  MuxAudio
//
//  Created by Emiaostein on 2018/7/20.
//  Copyright © 2018 Emiaostein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 Apple examples.
 https://developer.apple.com/library/archive/samplecode/iOSMultichannelMixerTest/Introduction/Intro.html
 https://developer.apple.com/library/archive/samplecode/sc2195/Introduction/Intro.html
*/

@interface MuxAudioManager : NSObject


/**
 Mux the audio to play.

 @param path The local audio file path.
 @param loop Whether does the audio play with loop. PS: There is only one at most that a loop audio to play.
 */
- (NSString *)playAudioFileAt:(NSString *)path loop:(BOOL)loop;


/**
 Stop the specifical audio.

 @param audioID The local audio file path.
 */
- (void)stopAudioFileBy:(NSString *)audioID;


- (void)stopAll;


/**
 Release memory,such as, audio file buffer in memory.
 */
- (void)cleanAll;


- (void)beganMixPCMBuffer;


- (NSData *__nullable)nextMixedPCMBuffer;


- (void)stopMixPCMBuffer;


@end
