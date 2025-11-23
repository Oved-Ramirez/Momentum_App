//
//  BodyStatsView.swift
//  Momentum
//  Body statistics input screen for onboarding
//
//  Created by Oved Ramirez on 11/23/25.
//

import SwiftUI

struct BodyStatsView: View {
   @Bindable var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, age, weight, height
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Text(viewModel.currentStep.title)
                    .font(Theme.Fonts.title)
                    .foregroundColor(Theme.Colors.text)
                
                Text("Tell us a bit about yourself")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            .padding(.top, Theme.Spacing.xl)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Name
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Name")
                            .font(Theme.Fonts.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField("Your name", text: $viewModel.userName)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .name)
                    }
                    
                    // Age
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Age")
                            .font(Theme.Fonts.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField("Age", text: $viewModel.age)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .age)
                        
                        if !viewModel.age.isEmpty && !viewModel.isAgeValid {
                            Text("Please enter a valid age (13-120)")
                                .font(Theme.Fonts.caption)
                                .foregroundColor(Theme.Colors.error)
                        }
                    }
                    
                    // Unit System Toggle
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Unit System")
                            .font(Theme.Fonts.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        Picker("Units", selection: $viewModel.useMetric) {
                            Text("Imperial (lb, in)").tag(false)
                            Text("Metric (kg, cm)").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Weight
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Weight (\(viewModel.useMetric ? "kg" : "lb"))")
                            .font(Theme.Fonts.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField("Weight", text: $viewModel.weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .weight)
                        
                        if !viewModel.weight.isEmpty && !viewModel.isWeightValid {
                            Text("Please enter a valid weight")
                                .font(Theme.Fonts.caption)
                                .foregroundColor(Theme.Colors.error)
                        }
                    }
                    
                    // Height
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Height (\(viewModel.useMetric ? "cm" : "inches"))")
                            .font(Theme.Fonts.bodyBold)
                            .foregroundColor(Theme.Colors.text)
                        
                        TextField("Height", text: $viewModel.height)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .height)
                        
                        if !viewModel.height.isEmpty && !viewModel.isHeightValid {
                            Text("Please enter a valid height")
                                .font(Theme.Fonts.caption)
                                .foregroundColor(Theme.Colors.error)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
            .onTapGesture {
                focusedField = nil
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: Theme.Spacing.md) {
                Button {
                    viewModel.previousStep()
                } label: {
                    Text("Back")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .secondaryButtonStyle()
                
                Button {
                    focusedField = nil
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .font(Theme.Fonts.bodyBold)
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1 : 0.5)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.bottom, Theme.Spacing.lg)
        }
    }
}

#Preview {
    BodyStatsView(viewModel: OnboardingViewModel())
}
