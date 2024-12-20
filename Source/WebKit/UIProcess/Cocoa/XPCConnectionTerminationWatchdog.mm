/*
 * Copyright (C) 2022 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "config.h"
#import "XPCConnectionTerminationWatchdog.h"

#import "AuxiliaryProcessProxy.h"
#import "ProcessAssertion.h"
#import "XPCUtilities.h"
#import <wtf/RunLoop.h>

namespace WebKit {

void XPCConnectionTerminationWatchdog::startConnectionTerminationWatchdog(AuxiliaryProcessProxy& process, Seconds interval)
{
    auto watchDog = makeUniqueRef<XPCConnectionTerminationWatchdog>(process);
    RunLoop::protectedMain()->dispatchAfter(interval, [watchDog = WTFMove(watchDog)] {
        watchDog->terminateProcess();
    });
}
    
XPCConnectionTerminationWatchdog::XPCConnectionTerminationWatchdog(AuxiliaryProcessProxy& process)
    : m_assertion(ProcessAndUIAssertion::create(process, "XPCConnectionTerminationWatchdog"_s, ProcessAssertionType::Background))
#if USE(EXTENSIONKIT_PROCESS_TERMINATION)
    , m_process(process.extensionProcess())
#else
    , m_xpcConnection(process.connection().xpcConnection())
#endif
{
}
    
void XPCConnectionTerminationWatchdog::terminateProcess()
{
#if USE(EXTENSIONKIT_PROCESS_TERMINATION)
    if (m_process)
        m_process->invalidate();
#else
    terminateWithReason(m_xpcConnection.get(), ReasonCode::WatchdogTimerFired, "XPCConnectionTerminationWatchdog::watchdogTimerFired");
#endif
}

} // namespace WebKit
