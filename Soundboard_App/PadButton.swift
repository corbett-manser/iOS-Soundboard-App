//
//  PadButton.swift
//  Soundboard_App
//
//  Created by Corbett Manser on 11/11/26.
//


import SwiftUIstruct PadButton: View {    let pad: Pad    let action: () -> Void    var body: some View {        Button(action: action) {            VStack(spacing: 6) {                Image(systemName: pad.fileName == nil ? "plus.circle" : "play.fill")                    .font(.title2)                Text(pad.title)                    .font(.footnote.weight(.semibold))                    .lineLimit(2)                    .multilineTextAlignment(.center)            }            .foregroundStyle(.white)            .frame(maxWidth: .infinity, minHeight: 100)            .padding(8)            .background(pad.fileName == nil ? Color.gray : Color.blue,                        in: RoundedRectangle(cornerRadius: 16))        }        .buttonStyle(.plain)    }}