#--
# Copyright (c) 2005-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Ruote

  module MiscMethods

    WAIT_MESSAGES = %w[ terminated cancel error ].collect { |m| m.to_sym }

    # Suspends the execution of the current thread and wait for the termination
    # (or error or cancellation) of a given process instance.
    #
    def wait_for (wfid)

      if defined?(EM) and EM.reactor_running?
        sleep 0.001
        return
      end

      # why doesn't this work with EM ?
      # EM as Thread.new { EM.run { } } maybe

      t = Thread.current
      result = nil

      sub = wqueue.subscribe(:processes) do |eclass, emessage, args|
        if args[:wfid] == wfid && WAIT_MESSAGES.include?(emessage)
          result = [ emessage, args ]
          t.wakeup
        end
      end

      #yield if block_given?

      begin
        Thread.stop unless result
      rescue Exception => e
        #p [ :wait_for, e ]
        # ignore
      end

      wqueue.remove_subscriber(sub)

      result
    end
  end
end

